# Introduction #

Add your content here.


# Details #

# Nested Classes #

Non-static nested classes 可以访问外部class的任意成员，而static的不能。

http://docs.oracle.com/javase/tutorial/java/javaOO/nested.html
# Java's Synthetic Methods
The access$x methods are created if you access private methods or variables from a nested class (or the other way around, or from one nested class to another). They are created by the compiler, since the VM does not allow direct access to private variables.

If the decompiler lets these method calls stay in the recreated source code for the using class, it should also let the synthetic methods definitions stay in the recreated source code for the used class. If so, have a look at the class which is the receiver of the method in question (class1 in your case), there should be such a method (access$17). In the code of this method you can see which real method (or variable) is accessed here.

If the decompiler removed the synthetic methods, this is either a bug, or it may be configurable. It could also be that you have to pass it all the classes at once, and then it can put in the right methods/fields everywhere - look at its documentation.

# JNI->java
## Using javap to Generate Method Signatures
To eliminate the mistakes in deriving method signatures by hand, you can use the javap tool to print out method signatures. For example, by running:
`javap -s -p bin/classes/com/idsee/ar/activity/HomeActivity.class`