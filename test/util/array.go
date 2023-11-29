package util

func Filter[T any](arr *[]T, f func(T) bool) *[]T {
	var filtered []T
	for _, v := range *arr {
		if f(v) {
			filtered = append(filtered, v)
		}
	}
	return &filtered
}

func Every[T any](arr *[]T, f func(T) bool) bool {
	for _, v := range *arr {
		if !f(v) {
			return false
		}
	}
	return true
}

func Some[T any](arr *[]T, f func(T) bool) bool {
	for _, v := range *arr {
		if f(v) {
			return true
		}
	}
	return false
}
