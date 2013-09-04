package com.github.xtension

import com.google.common.collect.Lists
import java.util.List

final class ListExtensions {

	private new(){
	}

  /**
   * Applies a binary operator to all elements of this list and a start value, going right to left.
   *
   * @param list
   * 		the list to be right folded
   * @param seed
   * 		the start value
   * @param operator
   * 		the binary operator which applied to consecutive elements of this list
   *
   * @return
   * 		the result of inserting {@code operator} between consecutive elements of this list,
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
   *		where x_1, x_2, ... , x_n are the elements of this list.
   */
	def static <T, R> R foldRight(List<T> list, R seed, (R, T) => R operator) {
		Lists::reverse(list).fold(seed, operator)
	}
}