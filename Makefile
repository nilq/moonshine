build:
	moonc */*.moon

imagereg:
	moonc image_regression/*.moon
	love image_regression
