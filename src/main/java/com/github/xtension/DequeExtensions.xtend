package com.github.xtension

import java.util.Deque

import static com.google.common.base.Preconditions.*

final class DequeExtensions {

	private new() {
	}

  /**
   * Applies a binary operator to all elements of this deque and a start value, going right to left.
   *
   * @param deque
   * 		the deque to be right folded
   * @param seed
   * 		the start value
   * @param operator
   * 		the binary operator which applied to consecutive elements of this deque
   *
   * @return
   * 		the result of inserting {@code operator} between consecutive elements of this deque,
   * 		going right to left with the start value {@code seed} on the right:
   *
   * <pre>
   *     op
   *    /  \
   *  x_1  op
   *      /  \
   *    x_2   .
   *           .
   *            \
   *            op
   *           /  \
   *         x_n  seed</pre>
   *
   *		where x_1, x_2, ... , x_n are the elements of this deque.
   */
	def static <T, R> R foldRight(Deque<T> deque, R seed, (R, T) => R operator) {
		var result = seed
		val iterator = deque.descendingIterator

		while (iterator.hasNext) {
			result = operator.apply(result, iterator.next)
		}

		result
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
