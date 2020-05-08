# Precision, Hardware Support and Performance
One complication of float/half/fixed data type usage is that PC GPUs are always high precision. 
That is, for all the PC (Windows/Mac/Linux) GPUs, it does not matter whether you write float, 
half or fixed data types in your shaders. They always compute everything in full 32-bit floating point precision.

The half and fixed types only become relevant when targeting mobile GPUs, 
where these types primarily exist for power (and sometimes performance) constraints. 
Keep in mind that you need to test your shaders on mobile to see whether or not you are running into precision/numerical issues.

Even on mobile GPUs, the different precision support varies between GPU families. 