//: # ARC & Memory
//:
//: Purpose of this playground is to help explain ARC and other memory related topics
//:
//: ## ARC - Automatic Reference Counting
//:
//: Swift uses ARC to help manage the memory for reference objects.
//:
//: #### Reference vs Value
//:
//: It is important to understand the distinction between these two types. Often in Swift you may hear developers talk about 'pass by value' versus 'pass by reference'. So let us try to make the distinction clear
//:
//: Let's start with Value types. `Struct`, `enum` are examples of value types. The term value type basically indicates that each instance keeps a unique copy of its data.

struct Foo {
    var data : String
}

var a = Foo(data:"initial")
let b = a
a.data = "consequential"
print(b.data)
print(a.data)
a.data != b.data

//: The code above simply demonstrates operations on a Value type. When a `struct` (a value type) gets passed around it is passed by value and thus `b` has a complete unique copy of data compared to `a`.
//: On the other hand, any `class` is a reference type. This means that each time we pass a refrence type around we are merely passing a pointer to the data.

class Fizz {
    var data : String
    init(data: String) {
        self.data = data
    }
}

let c = Fizz(data: "initial")
let d = c
c.data = "inconsequential"
print(d.data)

//: The code above demonstrates the "shared data" concept. Really what is happening is that `c` is just a reference to a `Fizz` object, and when we assign `d = c`, `d` now essentially points to the same object.

//Same memory address
print(Unmanaged.passUnretained(c).toOpaque())
print(Unmanaged.passUnretained(d).toOpaque())

//: Now that we have some distinction between the 2 types. How does this affect memory allocation and clean up?
//: In order to understand the role of ARC and how it affects memory allocation we first need to understand some other concepts.
//:
//: #### Memory
//: As far as I understand, memory is seggregated into 2 primary sections when a program is run.
//: ##### Stack
//: The stack is a segment of memory set aside for a program when it starts running and it behaves like a stack data structure.
//: Depending on platforms there may be varying scenarious but in most systems every thread that is in execution will have a stack. When operations/functions are executed on that thread the stack is used to store the location of those functions and operations in LIFO order. (That's why stacktraces are useful for debugging)
//: Memory can be allocated onto the stack.
//:
//: ##### Heap
//: The heap's purpose is dynamic runtime allocation of memory. Unlike a stack, things can be allocated and deallocated onto the heap at any point in time. There is no order of access (No LIFO/FIFO etc). Most of the time each application has 1 heap, whereas each thread has a stack. (Though we should note it is possible to have multiple different heaps per application for handling different types of allocation)
//:
//: So how does all of that relate to reference vs value types?
//: Value types are often allocated onto the stack. Since they aren't really "objects" and really just a set of data, that data is easily placed onto the stack. Thus when a value type gets created or copied during the execution of a function, that value's data is part of the executing thread's stack.
//: - Note: I should probably mention that there are certain exceptions or special cases. I am pretty sure some value types in swift like "Array" are potentially backed by a reference object? (Would probably have parse some swift source code to really figure out what is going on. We'll do that at some point in time)
//:
//: On the other hand refrence types are allocated onto the heap. As such, when a reference type gets created, it very likely ends up in heap space. (There may be optimizations that keep certain reference types in the stack until required to be in the heap?)


let refObject = Fizz(data: "reference object")
print(Unmanaged.passUnretained(refObject).toOpaque())

//: Therein lies the reason why ARC is specific to reference objects and not value types. Because value types exist on the stack, they are easily created and destroyed based on the stack pointer. The nature of "pass by value" means that "instances" of value types always exists distinctly in the stack. This is however untrue for reference types;
//: This behavior is actually quite evident through the use of the "allocations" tool in the profiling instruments tool suite. If you were to write a programe which generated a whole ton of persistent reference type objects, you'd notice that the "All heap" size goes up and so does the persistent count. However, do the same for value types and barely any change is noticed.
//:
//: Before creation of reference type objects
//:
//: ![Image of Heap allocation before creation of reference types](before.png "Image of Heap allocation before creation of reference types")
//:
//: After creation of reference type objects
//:
//: ![Image of Heap allocation after creation of reference types](after.png "Image of Heap allocation after creation of reference types")
//:
//: The same behavior cannot be seen with value types.
//:
//: When a reference object is created (e.g. an instance of a class), a block of memory is allocated on the heap and the data for that object is placed within said memory.Before the existence of ARC it would be the job of the developer to alloc and dealloc that memory.
//: Now, the developer has no need to concern themselves with that. ARC does most of the work. Each time an object is created, ARC allocates some memory to keep track of vital information regarding the object. This include how many references to the object there are.
//:
//: ARC will only release objects when their reference counts drop to 0.

class MyClass {
    init() {
        print("Initializing MyClass \(Unmanaged.passUnretained(self).toOpaque())")
    }
    
    deinit {
        print("deInitializing MyClass \(Unmanaged.passUnretained(self).toOpaque())")
    }
}

print("Initializing object A")
var objectA: MyClass? = MyClass.init()
var objectB: MyClass? = objectA // The initial instance of MyClass created in the line above now has 2 references
objectA = nil // Still has 1 rerference.
//Uncommenting the line below will result in the deinitialization of the original instance
//objectB = nil // Drops the reference count to 0

//: The addition of ARC also resulted in the addition of the weak and strong lifetime qualifiers.
//: When we make assignments to properties we are potentially performing an action that may incur an addition on the reference count of an object.

print("Initializing object C")
var objectC: MyClass? = MyClass.init()
class YourClass {
    var foo:MyClass?
}
var yourObject = YourClass()
yourObject.foo = objectC
objectC = nil
//Note the instance of MyClass created in the assignment of objectC does not actually get deallocated until the line below is uncommented.
//yourObject.foo = nil

//: The default lifetime qualifier is `strong`. However if you were to specify a weak qualifier, the assignement would not incur an additional reference count

print("Initializing object D")
var objectD: MyClass? = MyClass.init()
class YourWeakClass {
    weak var foo:MyClass?
}
var weakVarObject = YourWeakClass()
weakVarObject.foo = objectD
print("Object D getting deinitialized")
objectD = nil

//: - Note: In the example above. The instance created in the assignment line of object D gets deinitialized the moment Object D gets set to Nil because the `weak var` doesn't actually add a reference count.

