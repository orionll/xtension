package com.github.xtension

import java.util.Deque

import static com.google.common.base.Preconditions.*

final class DequeExtensions {

	private new() {
	}

	/**
	 * Removes the first {@code n} elements of this deque.
	 */
	def static void trimStart(Deque<?> deque, int n) {
		checkArgument(n >= 0, "Cannot remove a negative number of elements. Argument 'n' was: %s", n)

		for (i : 0 ..< n) {
			deque.removeFirst
		}
	}

	/**
	 * Removes the last {@code n} elements of this deque.
	 */
	def static void trimEnd(Deque<?> deque, int n) {
		checkArgument(n >= 0, "Cannot remove a negative number of elements. Argument 'n' was: %s", n)

		for (i : 0 ..< n) {
			deque.removeLast
		}
	}
}
