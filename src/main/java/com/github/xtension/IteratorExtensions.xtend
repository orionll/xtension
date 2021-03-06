package com.github.xtension

import com.google.common.annotations.Beta
import com.google.common.base.Optional
import com.google.common.collect.Iterators
import com.google.common.collect.Maps
import com.google.common.collect.Ordering
import com.google.common.math.IntMath
import com.google.common.math.LongMath
import java.util.Comparator
import java.util.Iterator
import java.util.List
import java.util.Map
import java.util.RandomAccess
import org.eclipse.xtext.xbase.lib.Pair

import static com.google.common.base.Preconditions.*

import static extension com.github.xtension.MapExtensions.*

final class IteratorExtensions {

	private new() {
	}

	/**
	 * Returns an {@link Optional} containing the first element in this iterator.
	 * If the iterator is empty, {@code Optional.absent()} is returned.
	 *
	 * @throws NullPointerException if the first element is null; if this is a possibility, use
	 *	{@link org.eclipse.xtext.xbase.lib.IteratorExtensions#head} instead.
	 */
	def static <T> Optional<T> headOptional(Iterator<T> iterator) {
		if (iterator.hasNext) {
			Optional::of(iterator.next)
		} else {
			Optional::absent
		}
	}

	/**
	 * Returns an {@link Optional} containing the last element in this iterator.
	 * If the iterator is empty, {@code Optional.absent()} is returned.
	 *
	 * @throws NullPointerException if the last element is null; if this is a possibility, use
	 *	{@link org.eclipse.xtext.xbase.lib.IteratorExtensions#last} instead.
	 */
	def static <T> Optional<T> lastOptional(Iterator<T> iterator) {
		if (iterator.hasNext) {
			var T last = null
			while (iterator.hasNext) {
				last = iterator.next
			}

			Optional::of(last)
		} else {
			Optional::absent
		}
	}

	/**
	 * Returns an {@link Optional} containing the first element in this iterator that
	 * satisfies the given predicate, if such an element exists. If no such element is found,
	 * {@code Optional.absent()} will be returned from this method and the the iterator will
	 * be left exhausted: its hasNext() method will return false.
	 *
	 * <p><b>Warning:</b> avoid using a {@code predicate} that matches {@code null}. If {@code null}
	 * is matched in this iterator, a {@link NullPointerException} will be thrown.
	 */
	def static <T> Optional<T> findFirstOptional(Iterator<T> iterator, (T) => boolean predicate) {
		Iterators::tryFind(iterator, predicate)
	}

	/**
	 * Counts the number of elements in this iterator which satisfy a predicate.
	 */
	def static <T> int count(Iterator<T> iterator, (T) => boolean predicate) {
		var count = 0
		while (iterator.hasNext) {
			if (predicate.apply(iterator.next)) {
				count = count + 1
			}
		}

		count
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
	 * Zips this iterator with its indices.
	 *
	 * <p>The resulting iterator's iterator does not support {@code remove()}.
	 */
	def static <T> Iterator<Pair<T, Integer>> zipWithIndex(Iterator<T> iterator) {
		iterator.zip((0 .. Integer::MAX_VALUE).iterator)
	}

	/**
	 * Returns an iterator formed from this iterator and another iterator by combining
	 * corresponding elements in pairs. If one of the two iterators is longer than the other,
	 * its remaining elements are ignored.
	 *
	 * <p>The resulting iterator does not support {@code remove()}.
	 */
	def static <T, U> Iterator<Pair<T, U>> zip(Iterator<T> a, Iterator<U> b) {
		zip(a, b, [x, y | x -> y])
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
	 * Returns an iterator containing the elements greater than or equal to index {@code from} extending
	 * up to (but not including) index {@code until} of this iterator.
	 *
	 * <p>The source iterator is not polled until necessary. The resulting iterator's iterator does
	 * not support {@code remove()}.
	 */
	def static <T> Iterator<T> slice(Iterator<T> iterator, int from, int until) {
		checkArgument(from >= 0, "Argument 'from' was negative: %s", from)
		checkArgument(until >= 0, "Argument 'until' was negative: %s", until)

		if (until <= from) {
			Iterators::emptyIterator
		} else {
			iterator.drop(from).take(until - from)
		}
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
	 * Divides this iterator into unmodifiable sublists of the given size (the final list may be
	 * smaller). For example, grouping an iterator containing {@code [a, b, c, d, e]} with a group
	 * size of 3 yields {@code [[a, b, c], [d, e]]} -- an outer iterator containing two inner lists
	 * of three and two elements, all in the original order.
	 *
	 * <p>The returned iterator does not support the {@link Iterator#remove()} method.
	 * The returned lists implement {@link RandomAccess}.
	 *
	 * @return an iterable of unmodifiable lists containing the elements of {@code iterator} divided
	 *	into groups
	 * @throws IllegalArgumentException if {@code size} is nonpositive
	 */
	def static <T> Iterator<List<T>> grouped(Iterator<T> iterator, int size) {
		Iterators::partition(iterator, size)
	}

	/**
	 * Groups elements of this iterator in fixed size blocks by passing a "sliding window" over them
	 * (as opposed to partitioning them, as is done in {@link #grouped}.)
	 *
	 * <p>Iterators returned by the returned iterator do not support {@code remove()}.
	 *
	 * @return an iterator of unmodifiable lists of size {@code size}, except the last and the only element
	 * will be truncated if there are fewer elements than {@code size}.
	 */
	def static <T> Iterator<List<T>> sliding(Iterator<T> iterator, int size) {
		checkArgument(size >= 1, "Illegal sliding size: %s", size)
		new SlidingItr(iterator, size)
	}

	/**
	 * Partitions this iterator into a map of lists according to some discriminator function.
	 *
	 * <p>The resulting map and lists are unmodifiable.
	 */
	def static <T, K> Map<K, List<T>> groupBy(Iterator<T> iterator, (T) => K function) {
		val map = Maps::<K, List<T>>newHashMap
		val newArrayList = [| newArrayList]

		while (iterator.hasNext) {
			val elem = iterator.next
			val key = function.apply(elem)
			map.getOrElseUpdate(key, newArrayList).add(elem)
		}

		for (key : map.keySet) {
			map.put(key, map.get(key).unmodifiableView)
		}

		map.unmodifiableView
	}

	/**
	 * Finds the index of the first element that satisfies a predicate.
	 *
	 * @return the index of the first element of this iterator that satisfies the predicate,
	 * or {@code -1}, if no elements satisfy the predicate.
	 */
	def static <T> int indexWhere(Iterator<T> iterator, (T) => boolean predicate) {
		iterator.indexWhere(0, predicate)
	}

	/**
	 * Finds the index of the first element that satisfies a predicate after or at some start index.
	 *
	 * @return the index {@code >= from} of the first element of this iterator that satisfies the predicate,
	 * or {@code -1}, if no elements satisfy the predicate.
	 */
	def static <T> int indexWhere(Iterator<T> iterator, int from, (T) => boolean predicate) {
		val drop = if (from == 0) iterator else iterator.drop(from)
		var i = from

		while (drop.hasNext) {
			if (predicate.apply(drop.next)) {
				return i
			}

			if (i == Integer::MAX_VALUE) {
				throw new ArithmeticException('No element that satisfies the predicate found. Index reached maximum value of 32-bit integer.')
			}
			i = i + 1
		}

		return -1
	}

	/**
	 * Finds the index of the last element that satisfies a predicate.
	 *
	 * @return the index of the last element of this iterator that satisfies the predicate,
	 * or {@code -1}, if no elements satisfy the predicate.
	 */
	def static <T> int lastIndexWhere(Iterator<T> iterator, (T) => boolean predicate) {
		var i = 0
		var last = -1

		while (iterator.hasNext) {
			if (predicate.apply(iterator.next)) {
				last = i
			}

			if (i == Integer::MAX_VALUE && iterator.hasNext) {
				throw new ArithmeticException('Index reached maximum value of 32-bit integer but there are still more elements.')
			}
			i = i + 1
		}

		last
	}

	/**
	 * Finds the index of the last element that satisfies a predicate before or at some end index.
	 *
	 * @return the index {@code <= end} of the last element of this iterator that satisfies the predicate,
	 * or {@code -1}, if no elements satisfy the predicate.
	 */
	def static <T> int lastIndexWhere(Iterator<T> iterator, int end, (T) => boolean predicate) {
		checkArgument(end >= 0, "Argument 'end' was negative: %s", end)

		var i = 0
		var last = -1

		while (iterator.hasNext) {
			if (i > end) {
				return last
			}
			if (predicate.apply(iterator.next)) {
				last = i
			}

			i = i + 1
		}

		last
	}

	/**
	 * Returns the minimum element of this iterator, according to the <i>natural ordering</i>
	 * of its elements. All elements in the iterator must implement the <tt>Comparable</tt>
	 * interface.
	 *
	 * @throws NoSuchElementException if the iterator is empty.
	 */
	def static <T extends Object & Comparable<? super T>> T min(Iterator<T> iterator) {
		iterator.min(Ordering::natural)
	}

	/**
	 * Returns the minimum element of this iterator, according to the order induced by
	 * the specified comparator.
	 *
	 * @throws NoSuchElementException if the iterator is empty.
	 */
	def static <T> T min(Iterator<T> iterator, Comparator<? super T> comp) {
		var min = iterator.next

		while (iterator.hasNext) {
			val next = iterator.next
			if (comp.compare(next, min) < 0) {
				min = next
			}
		}

		min
	}

	/**
	 * Returns an {@link Optional} containing the minimum element of this iterator,
	 * according to the <i>natural ordering</i> of its elements. All elements in the
	 * iterator must implement the <tt>Comparable</tt> interface.
	 *
	 * @throws NullPointerException if the min element is {@code null}; if this is
	 * a possibility, use {@link #min} instead.
	 */
	def static <T extends Object & Comparable<? super T>> Optional<T> minOptional(Iterator<T> iterator) {
		iterator.minOptional(Ordering::natural)
	}

	/**
	 * Returns an {@link Optional} containing the minimum element of this iterator,
	 * according to the order induced by the specified comparator.
	 *
	 * @throws NullPointerException if the min element is {@code null}; if this is
	 * a possibility, use {@link #min} instead.
	 */
	def static <T> Optional<T> minOptional(Iterator<T> iterator, Comparator<? super T> comp) {
		if (iterator.hasNext) {
			var min = iterator.next

			while (iterator.hasNext) {
				val next = iterator.next
				if (comp.compare(next, min) < 0) {
					min = next
				}
			}

			Optional::of(min)
		} else {
			Optional::absent
		}
	}

	/**
	 * Returns the minimum element of this iterator based on the given transformation,
	 * according to the <i>natural ordering</i> of the values.
	 *
	 * @throws NoSuchElementException if the iterator is empty.
	 */
	def static <T, U extends Object & Comparable<? super U>> T minBy(Iterator<T> iterator, (T) => U function) {
		iterator.minBy(Ordering::natural, function)
	}

	/**
	 * Returns the minimum element of this iterator based on the given transformation,
	 * according to the order induced by the specified comparator.
	 *
	 * @throws NoSuchElementException if the iterator is empty.
	 */
	def static <T, U> T minBy(Iterator<T> iterator, Comparator<? super U> comp, (T) => U function) {
		var min = iterator.next

		while (iterator.hasNext) {
			val next = iterator.next
			if (comp.compare(function.apply(next), function.apply(min)) < 0) {
				min = next
			}
		}

		min
	}

	/**
	 * Returns an {@link Optional} containing the minimum element of this iterator based on
	 * the given transformation, according to the <i>natural ordering</i> of the values.
	 *
	 * @throws NullPointerException if the min element is {@code null}; if this is
	 * a possibility, use {@link #minBy} instead.
	 */
	def static <T, U extends Object & Comparable<? super U>> Optional<T> minByOptional(Iterator<T> iterator, (T) => U function) {
		iterator.minByOptional(Ordering::natural, function)
	}

	/**
	 * Returns an {@link Optional} containing the minimum element of this iterator based on
	 * the given transformation, according to the order induced by the specified comparator.
	 *
	 * @throws NullPointerException if the min element is {@code null}; if this is
	 * a possibility, use {@link #minBy} instead.
	 */
	def static <T, U> Optional<T> minByOptional(Iterator<T> iterator, Comparator<? super U> comp, (T) => U function) {
		if (iterator.hasNext) {
			var min = iterator.next

			while (iterator.hasNext) {
				val next = iterator.next
				if (comp.compare(function.apply(next), function.apply(min)) < 0) {
					min = next
				}
			}

			Optional::of(min)
		} else {
			Optional::absent
		}
	}

	/**
	 * Returns the maximum element of this iterator, according to the <i>natural ordering</i>
	 * of its elements. All elements in the iterator must implement the <tt>Comparable</tt>
	 * interface.
	 *
	 * @throws NoSuchElementException if the iterator is empty.
	 */
	def static <T extends Object & Comparable<? super T>> T max(Iterator<T> iterator) {
		iterator.max(Ordering::natural)
	}

	/**
	 * Returns the maximum element of this iterator, according to the order induced by
	 * the specified comparator.
	 *
	 * @throws NoSuchElementException if the iterator is empty.
	 */
	def static <T> T max(Iterator<T> iterator, Comparator<? super T> comp) {
		var max = iterator.next

		while (iterator.hasNext) {
			val next = iterator.next
			if (comp.compare(next, max) > 0) {
				max = next
			}
		}

		max
	}

	/**
	 * Returns an {@link Optional} containing the maximum element of this iterator,
	 * according to the <i>natural ordering</i> of its elements. All elements in the
	 * iterator must implement the <tt>Comparable</tt> interface.
	 *
	 * @throws NullPointerException if the max element is {@code null}; if this is
	 * a possibility, use {@link #max} instead.
	 */
	def static <T extends Object & Comparable<? super T>> Optional<T> maxOptional(Iterator<T> iterator) {
		iterator.maxOptional(Ordering::natural)
	}

	/**
	 * Returns an {@link Optional} containing the maximum element of this iterator,
	 * according to the order induced by the specified comparator.
	 *
	 * @throws NullPointerException if the max element is {@code null}; if this is
	 * a possibility, use {@link #max} instead.
	 */
	def static <T> Optional<T> maxOptional(Iterator<T> iterator, Comparator<? super T> comp) {
		if (iterator.hasNext) {
			var max = iterator.next

			while (iterator.hasNext) {
				val next = iterator.next
				if (comp.compare(next, max) > 0) {
					max = next
				}
			}

			Optional::of(max)
		} else {
			Optional::absent
		}
	}

	/**
	 * Returns the maximum element of this iterator based on the given transformation,
	 * according to the <i>natural ordering</i> of the values.
	 *
	 * @throws NoSuchElementException if the iterator is empty.
	 */
	def static <T, U extends Object & Comparable<? super U>> T maxBy(Iterator<T> iterator, (T) => U function) {
		iterator.maxBy(Ordering::natural, function)
	}

	/**
	 * Returns the maximum element of this iterator based on the given transformation,
	 * according to the order induced by the specified comparator.
	 *
	 * @throws NoSuchElementException if the iterator is empty.
	 */
	def static <T, U> T maxBy(Iterator<T> iterator, Comparator<? super U> comp, (T) => U function) {
		var max = iterator.next

		while (iterator.hasNext) {
			val next = iterator.next
			if (comp.compare(function.apply(next), function.apply(max)) > 0) {
				max = next
			}
		}

		max
	}

	/**
	 * Returns an {@link Optional} containing the maximum element of this iterator based on
	 * the given transformation, according to the <i>natural ordering</i> of the values.
	 *
	 * @throws NullPointerException if the max element is {@code null}; if this is
	 * a possibility, use {@link #maxBy} instead.
	 */
	def static <T, U extends Object & Comparable<? super U>> Optional<T> maxByOptional(Iterator<T> iterator, (T) => U function) {
		iterator.maxByOptional(Ordering::natural, function)
	}

	/**
	 * Returns an {@link Optional} containing the maximum element of this iterator based on
	 * the given transformation, according to the order induced by the specified comparator.
	 *
	 * @throws NullPointerException if the max element is {@code null}; if this is
	 * a possibility, use {@link #maxBy} instead.
	 */
	def static <T, U> Optional<T> maxByOptional(Iterator<T> iterator, Comparator<? super U> comp, (T) => U function) {
		if (iterator.hasNext) {
			var max = iterator.next

			while (iterator.hasNext) {
				val next = iterator.next
				if (comp.compare(function.apply(next), function.apply(max)) > 0) {
					max = next
				}
			}

			Optional::of(max)
		} else {
			Optional::absent
		}
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
