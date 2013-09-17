package com.github.xtension

import java.util.Iterator

final class IteratorsExtensions {

	private new() {
	}

	/**
	 * Returns an iterator formed from this iterator and another iterator by combining
	 * corresponding elements according to an operator. If one of the two iterators is longer than the other,
	 * its remaining elements are ignored.
	 *
	 * <p>The resulting iterator does not support {@code remove()}.
	 */
	def static <T, U, R> Iterator<R> zip(Iterator<T> a, Iterator<U> b, (T, U) => R operator) {
		new ZipItr(a, b, operator)
	}

	/**
	 * Takes longest prefix of elements that satisfy a predicate.
	 *
	 * <p>The resulting iterator does not support {@code remove()}.
	 */
	def static <T> Iterator<T> takeWhile(Iterator<T> iterator, (T) => boolean predicate) {
		new TakeWhileItr(iterator, predicate)
	}

	/**
	 * Drops longest prefix of elements that satisfy a predicate.
	 *
	 * <p>The resulting iterator does not support {@code remove()}.
	 */
	def static <T> Iterator<T> dropWhile(Iterator<T> iterator, (T) => boolean predicate) {
		new DropWhileItr(iterator, predicate)
	}

	/**
	 * Returns an iterable containing cumulative results of applying the operator going left to right.
	 *
	 * <p>The resulting iterator does not support {@code remove()}.
	 */
	def static <T, U> Iterator<U> scan(Iterator<T> iterator, U seed, (U, T) => U function) {
		new ScanItr(iterator, seed, function)
	}
}
