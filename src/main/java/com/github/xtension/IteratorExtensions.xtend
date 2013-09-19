package com.github.xtension

import com.google.common.annotations.Beta
import com.google.common.collect.Iterators
import com.google.common.math.IntMath
import com.google.common.math.LongMath
import java.util.Iterator

final class IteratorExtensions {

	private new() {
	}

	/**
	 * Creates a new iterator by applying a function to all values produced by this iterator
	 * and concatenating the results.
	 *
	 * <p>The returned iterator supports {@code remove()} if this function-returned iterator does.
	 */
	def static <T, U> Iterator<U> flatMap(Iterator<T> iterator, (T) => Iterator<? extends U> function) {
		Iterators::concat(Iterators::transform(iterator, function))
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

	/**
	 * Sums up the elements of this iterator.
	 */
	@Beta
	def static<T> int sumInt(Iterator<Integer> iterator) {
		var sum = 0
		while (iterator.hasNext) {
			sum = IntMath::checkedAdd(sum, iterator.next)
		}

		sum
	}

	/**
	 * Sums up the elements of this iterator.
	 */
	@Beta
	def static<T> long sumLong(Iterator<Long> iterator) {
		var sum = 0L
		while (iterator.hasNext) {
			sum = LongMath::checkedAdd(sum, iterator.next)
		}

		sum
	}

	/**
	 * Sums up the elements of this iterator.
	 */
	@Beta
	def static<T> double sumDouble(Iterator<Double> iterator) {
		var sum = 0.0
		while (iterator.hasNext) {
			sum = sum + iterator.next
		}

		sum
	}
}
