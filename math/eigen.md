# Array, matrix and vector types
```
typedef Matrix<Scalar, RowsAtCompileTime, ColsAtCompileTime, Options> MyMatrixType;
typedef Array<Scalar, RowsAtCompileTime, ColsAtCompileTime, Options> MyArrayType;
```
* Scalar is the scalar type of the coefficients (e.g., float, double, bool, int, etc.).
* RowsAtCompileTime and ColsAtCompileTime are the number of rows and columns of the matrix as known at compile-time or Dynamic.
* Options can be ColMajor or RowMajor, default is ColMajor. (see class Matrix for more options)

```
Matrix<double, 6, Dynamic>                  // Dynamic number of columns (heap allocation)
Matrix<double, Dynamic, 2>                  // Dynamic number of rows (heap allocation)
Matrix<double, Dynamic, Dynamic, RowMajor>  // Fully dynamic, row major (heap allocation)
Matrix<double, 13, 3>                       // Fully fixed (usually allocated on stack)
```
Matrices
```
Matrix<float,Dynamic,Dynamic>   <=>   MatrixXf
Matrix<double,Dynamic,1>        <=>   VectorXd
Matrix<int,1,Dynamic>           <=>   RowVectorXi
Matrix<float,3,3>               <=>   Matrix3f
Matrix<float,4,1>               <=>   Vector4f
```
Arrays
```
Array<float,Dynamic,Dynamic>    <=>   ArrayXXf
Array<double,Dynamic,1>         <=>   ArrayXd
Array<int,1,Dynamic>            <=>   RowArrayXi
Array<float,3,3>                <=>   Array33f
Array<float,4,1>                <=>   Array4f
```
Conversion between the matrix and array worlds:
```
Array44f a1, a1;
Matrix4f m1, m2;
m1 = a1 * a2;                     // coeffwise product, implicit conversion from array to matrix.
a1 = m1 * m2;                     // matrix product, implicit conversion from matrix to array.
a2 = a1 + m1.array();             // mixing array and matrix is forbidden
m2 = a1.matrix() + m1;            // and explicit conversion is required.
ArrayWrapper<Matrix4f> m1a(m1);   // m1a is an alias for m1.array(), they share the same coefficients
MatrixWrapper<Array44f> a1m(a1);
```
# Basic matrix manipulation
![matrix-man](/uploads/5455c7cfb2fb0240db0e4907e28f00cc/matrix-man.PNG)