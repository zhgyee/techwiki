# Strings as Return Values
The String type is a class, so see the section on returning classes from functions. 
** Summary: the runtime will attempt to free the returned pointer. **

If you don’t want the runtime to free the returned string, either (a) don’t specify the return value (as was done for the strncpy(3) function above), 
or (b) return an IntPtr and use one of the Marshal.PtrToString* functions, depending on the type of string returned. For example, use Marshal.PtrToStringAnsi to marshal from a Ansi string, and use Marshal.PtrToStringUni to marshal from a Unicode string.

[ref](http://www.mono-project.com/docs/advanced/pinvoke/)