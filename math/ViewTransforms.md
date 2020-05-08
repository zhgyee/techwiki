# clip-space to camera-space
The camera-space plane L corresponding to the clip-space play L' is given by `L=transpose(M)*L'`

| Plane | L'=<N,D\> | L=transpose(M)*L'	|
|-------|-----------|-------------------|
| Near	| <0,0,1,1>	| M3+M4				|
| Far 	| <0,0,-1,1>| M4-M3				|
| Left	| <1,0,0,1>	| M1+M4 			|
| Right	| <-1,0,0,1>| M4-M1				|
| Bottom| <0,1,0,1>	| M2+M4 			|
| Top 	| <0,-1,0,1>| M4-M2				|

## GetViewMatrixPosition
```
inline Vector3f GetViewMatrixPosition( Matrix4f const & m )
{
#if 1
	return m.Inverted().GetTranslation();
#else
	// This is much cheaper if the view matrix is a pure rotation plus translation.
	return Vector3f(	m.M[0][0] * m.M[0][3] + m.M[1][0] * m.M[1][3] + m.M[2][0] * m.M[2][3],
						m.M[0][1] * m.M[0][3] + m.M[1][1] * m.M[1][3] + m.M[2][1] * m.M[2][3],
						m.M[0][2] * m.M[0][3] + m.M[1][2] * m.M[1][3] + m.M[2][2] * m.M[2][3] );
#endif
}
```

## GetViewMatrixForward
```
inline Vector3f GetViewMatrixForward( Matrix4f const & m )
{
	return Vector3f( -m.M[2][0], -m.M[2][1], -m.M[2][2] ).Normalized();
}
```

# hit test