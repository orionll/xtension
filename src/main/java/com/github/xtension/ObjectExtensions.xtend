package com.github.xtension

import com.google.common.annotations.Beta

final class ObjectExtensions {

	private new() {
	}

	/**
	 * Determines whether the value matches any value in the given list.
	 * <p>Example:
	 * <p>{@code 'a'.in('a', 'b', 'c')} (returns {@code true})
	 */
	@Beta
	def static <T> boolean in(T obj, T other, T other2, T... others) {
		obj == other || obj == other2 || others.contains(obj)
	}

	/**
	 * Determines whether the value does not match any value in the given list.
	 * <p>Example:
	 * <p>{@code 'a'.notIn('c', 'd', 'e')} (returns {@code true})
	 */
	@Beta
	def static <T> boolean notIn(T obj, T other, T other2, T... others) {
		obj != other && obj != other2 && !others.contains(obj)
	}
}