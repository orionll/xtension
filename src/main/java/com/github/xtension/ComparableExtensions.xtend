package com.github.xtension

import com.google.common.annotations.Beta

final class ComparableExtensions {

	private new() {
	}

	/**
	 * Determines whether the value is in [start, end] range (start included, end included).
	 */
	@Beta
	def static <C> boolean isBetween(Comparable<? super C> obj, C start, C end) {
		obj.compareTo(start) >= 0 && obj.compareTo(end) <= 0
	}

	/**
	 * Determines whether the value value is in (start, end) range (start excluded, end excluded).
	 */
	@Beta
	def static <C> boolean isStrictlyBetween(Comparable<? super C> obj, C start, C end) {
		obj.compareTo(start) > 0 && obj.compareTo(end) < 0
	}
}