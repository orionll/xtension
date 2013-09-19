package com.github.xtension

final class StringExtensions {

	private new() {
	}

	/**
	 * Applies {@code procedure} for each element of this string.
	 */
	def static <T> forEach(String str, (char) => void procedure) {
		for (c : str.toCharArray) {
			procedure.apply(c)
		}
	}

	/**
	 * Builds a new string by applying a function to all elements of this string.
	 */
	def static String map(String str, (char) => char function) {
		val result = newCharArrayOfSize(str.length)

		var i = 0
		for (c : str.toCharArray) {
			result.set(i, function.apply(c))
			i = i + 1
		}

		new String(result)
	}

	/**
	 * Builds a new string by applying a function to all elements of this string.
	 */
	def static String flatMap(String str, (char) => String function) {
		val result = new StringBuilder

		var i = 0
		for (c : str.toCharArray) {
			result.append(function.apply(c))
			i = i + 1
		}

		result.toString
	}
}