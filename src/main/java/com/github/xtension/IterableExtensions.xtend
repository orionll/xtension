package com.github.xtension

import com.google.common.annotations.Beta
import com.google.common.base.Optional
import com.google.common.collect.FluentIterable
import com.google.common.collect.Iterables
import com.google.common.collect.Iterators
import com.google.common.collect.Lists
import com.google.common.collect.Ordering
import java.util.Collection
import java.util.Collections
import java.util.Comparator
import java.util.Iterator
import java.util.List
import java.util.Map
import java.util.RandomAccess
import org.eclipse.xtext.xbase.lib.Pair

import static com.google.common.base.Preconditions.*

import static extension com.github.xtension.IteratorExtensions.*

final class IterableExtensions {

	private new() {
	}

	/**
	 * Returns an {@link Optional} containing the first element in this iterable.
	 * If the iterable is empty, {@code Optional.absent()} is returned.
	 *
	 * @throws NullPointerException if the first element is null; if this is a possibility, use
	 *	{@link org.eclipse.xtext.xbase.lib.IterableExtensions#head} instead.
	 */
	def static <T> Optional<T> headOptional(Iterable<T> iterable) {
		FluentIterable::from(iterable).first
	}

	/**
	 * Returns an {@link Optional} containing the last element in this fluent iterable.
	 * If the iterable is empty, {@code Optional.absent()} is returned.
	 *
	 * @throws NullPointerException if the last element is null; if this is a possibility, use
	 *	{@link org.eclipse.xtext.xbase.lib.IterableExtensions#last} instead.
	 */
	def static <T> Optional<T> lastOptional(Iterable<T> iterable) {
		FluentIterable::from(iterable).last
	}

	/**
	 * Returns an {@link Optional} containing the first element in this iterable that
	 * satisfies the given predicate, if such an element exists.
	 *
	 * <p><b>Warning:</b> avoid using a {@code predicate} that matches {@code null}. If {@code null}
	 * is matched in this iterable, a {@link NullPointerException} will be thrown.
	 */
	def static <T> Optional<T> findFirstOptional(Iterable<T> iterable, (T) => boolean predicate) {
		Iterables::tryFind(iterable, predicate)
	}

	/**
	 * Builds a new iterable by applying a function to all elements of this iterable
	 * and using the elements of the resulting iterables.
	 * 
	 * <p>For example:
	 * 
	 * <p>{@code val words = lines.flatMap[split("\\W+").toList]}
	 *
	 * <p>The returned iterable's iterator supports {@code remove()} if this
	 * function-returned iterables' iterator does. After a successful {@code remove()} call,
	 * the returned iterable no longer contains the corresponding element.
	 */
	def static <T, U> Iterable<U> flatMap(Iterable<T> iterable, (T) => Iterable<? extends U> function) {
		FluentIterable::from(iterable).transformAndConcat(function)
	}

	/**
	 * Counts the number of elements in this iterable which satisfy a predicate.
	 */
	def static <T> int count(Iterable<T> iterable, (T) => boolean predicate) {
		iterable.iterator.count(predicate)
	}

	/**
	 * Produces the iterable of all indices of this iterable.
	 *
	 * @return	an iterable from 0 to one less than the size of this iterable.
	 */
	def static Iterable<Integer> indices(Iterable<?> iterable) {
		switch (iterable) {
			Collection<?> : 0 ..< iterable.size
			default : {
				val FluentIterable<Integer> result = [| new IndicesItr(iterable.iterator)]
				result
			}
		}
	} 

	/**
	 * Returns an iterable whose {@code Iterator} cycles indefinitely over the elements of
	 * this iterable.
	 *
	 * <p>That iterator supports {@code remove()} if {@code iterable.iterator()} does. After
	 * {@code remove()} is called, subsequent cycles omit the removed element, which is no longer in
	 * this iterable. The iterator's {@code hasNext()} method returns {@code true} until
	 * this iterable is empty.
	 *
	 * <p><b>Warning:</b> Typical uses of the resulting iterator may produce an infinite loop. You
	 * should use an explicit {@code break} or be certain that you will eventually remove all the
	 * elements.
	 */
	def static <T> Iterable<T> cycle(Iterable<T> iterable) {
		Iterables::cycle(iterable)
	}

	/**
	 * Returns an iterable formed from this iterable and another iterable by combining
	 * corresponding elements in pairs. If one of the two collections is longer than the other,
	 * its remaining elements are ignored. The source iterators are not polled until necessary.
	 *
	 * <p>The resulting iterable's iterator does not support {@code remove()}.
	 */
	def static <T, U> Iterable<Pair<T, U>> zip(Iterable<T> a, Iterable<U> b) {
		zip(a, b, [x, y | x -> y])
	}

	/**
	 * Returns an iterable formed from this iterable and another iterable by combining
	 * corresponding elements according to an operator. If one of the two collections is longer than the other,
	 * its remaining elements are ignored. The source iterators are not polled until necessary.
	 *
	 * <p>The resulting iterable's iterator does not support {@code remove()}.
	 */
	def static <T, U, R> Iterable<R> zip(Iterable<T> a, Iterable<U> b, (T, U) => R operator) {
		val FluentIterable<R> iterable = [| new ZipItr(a.iterator, b.iterator, operator)]
		iterable
	}

	/**
	 * Converts this iterable of pairs into two lists of the first and second
	 * half of each pair.
	 *
	 * <p>The resulting lists are unmodifiable.
	 */
	def static <T, U> Pair<Iterable<T>, Iterable<U>> unzip(Iterable<Pair<T, U>> iterable) {
		iterable.map[key] -> iterable.map[value]
	}

	/**
	 * Converts this iterable into two lists by applying a function to each element of this iterable.
	 *
	 * <p>The resulting lists are unmodifiable.
	 */
	def static <T, U, S> Pair<Iterable<T>, Iterable<U>> unzip(Iterable<S> iterable, (S) => Pair<T, U> function) {
		iterable.map[function.apply(it).key] -> iterable.map[function.apply(it).value]
	}

	/**
	 * Zips this iterable with its indices.
	 * 
	 * <p>The resulting iterable's iterator does not support {@code remove()}.
	 */
	def static <T> Iterable<Pair<T, Integer>> zipWithIndex(Iterable<T> iterable) {
		val FluentIterable<Pair<T, Integer>> result = [| iterable.iterator.zipWithIndex]
		result
	}

	/**
	 * Returns the minimum element of this iterable, according to the <i>natural ordering</i>
	 * of its elements. All elements in the iterable must implement the <tt>Comparable</tt>
	 * interface.
	 *
	 * @throws NoSuchElementException if the iterable is empty.
	 */
	def static <T extends Object & Comparable<? super T>> T min(Iterable<T> iterable) {
		iterable.min(Ordering::natural)
	}

	/**
	 * Returns the minimum element of this iterable, according to the order induced by
	 * the specified comparator.
	 *
	 * @throws NoSuchElementException if the iterable is empty.
	 */
	def static <T> T min(Iterable<T> iterable, Comparator<? super T> comp) {
		iterable.iterator.min(comp)
	}

	/**
	 * Returns an {@link Optional} containing the minimum element of this iterable,
	 * according to the <i>natural ordering</i> of its elements. All elements in the
	 * iterable must implement the <tt>Comparable</tt> interface.
	 *
	 * @throws NullPointerException if the min element is {@code null}; if this is
	 * a possibility, use {@link #min} instead.
	 */
	def static <T extends Object & Comparable<? super T>> Optional<T> minOptional(Iterable<T> iterable) {
		iterable.iterator.minOptional
	}

	/**
	 * Returns an {@link Optional} containing the minimum element of this iterable,
	 * according to the order induced by the specified comparator.
	 *
	 * @throws NullPointerException if the min element is {@code null}; if this is
	 * a possibility, use {@link #min} instead.
	 */
	def static <T> Optional<T> minOptional(Iterable<T> iterable, Comparator<? super T> comp) {
		iterable.iterator.minOptional(comp)
	}

	/**
	 * Returns the minimum element of this iterable based on the given transformation,
	 * according to the <i>natural ordering</i> of the values.
	 *
	 * @throws NoSuchElementException if the iterable is empty.
	 */
	def static <T, U extends Object & Comparable<? super U>> T minBy(Iterable<T> iterable, (T) => U function) {
		iterable.minBy(Ordering::natural, function)
	}

	/**
	 * Returns the minimum element of the this iterable based on the given transformation,
	 * according to the order induced by the specified comparator.
	 *
	 * @throws NoSuchElementException if the iterable is empty.
	 */
	def static <T, U> T minBy(Iterable<T> iterable, Comparator<? super U> comp, (T) => U function) {
		iterable.iterator.minBy(comp, function)
	}

	/**
	 * Returns an {@link Optional} containing the minimum element of this iterable based on
	 * the given transformation, according to the <i>natural ordering</i> of the values.
	 *
	 * @throws NullPointerException if the min element is {@code null}; if this is
	 * a possibility, use {@link #minBy} instead.
	 */
	def static <T, U extends Object & Comparable<? super U>> Optional<T> minByOptional(Iterable<T> iterable, (T) => U function) {
		iterable.iterator.minByOptional(function)
	}

	/**
	 * Returns an {@link Optional} containing the minimum element of this iterable based on
	 * the given transformation, according to the order induced by the specified comparator.
	 *
	 * @throws NullPointerException if the min element is {@code null}; if this is
	 * a possibility, use {@link #minBy} instead.
	 */
	def static <T, U> Optional<T> minByOptional(Iterable<T> iterable, Comparator<? super U> comp, (T) => U function) {
		iterable.iterator.minByOptional(comp, function)
	}

	/**
	 * Returns the maximum element of this iterable, according to the <i>natural ordering</i>
	 * of its elements. All elements in the iterable must implement the <tt>Comparable</tt>
	 * interface.
	 *
	 * @throws NoSuchElementException if the iterable is empty.
	 */
	def static <T extends Object & Comparable<? super T>> T max(Iterable<T> iterable) {
		iterable.max(Ordering::natural)
	}

	/**
	 * Returns the maximum element of the this iterable, according to the order induced by
	 * the specified comparator.
	 *
	 * @throws NoSuchElementException if the iterable is empty.
	 */
	def static <T> T max(Iterable<T> iterable, Comparator<? super T> comp) {
		iterable.iterator.max(comp)
	}

	/**
	 * Returns an {@link Optional} containing the maximum element of this iterable,
	 * according to the <i>natural ordering</i> of its elements. All elements in the
	 * iterable must implement the <tt>Comparable</tt> interface.
	 *
	 * @throws NullPointerException if the max element is {@code null}; if this is
	 * a possibility, use {@link #max} instead.
	 */
	def static <T extends Object & Comparable<? super T>> Optional<T> maxOptional(Iterable<T> iterable) {
		iterable.iterator.maxOptional
	}

	/**
	 * Returns an {@link Optional} containing the maximum element of this iterable,
	 * according to the order induced by the specified comparator.
	 *
	 * @throws NullPointerException if the max element is {@code null}; if this is
	 * a possibility, use {@link #max} instead.
	 */
	def static <T> Optional<T> maxOptional(Iterable<T> iterable, Comparator<? super T> comp) {
		iterable.iterator.maxOptional(comp)
	}

	/**
	 * Returns the maximum element of the this iterable based on the given transformation,
	 * according to the <i>natural ordering</i> of the values.
	 *
	 * @throws NoSuchElementException if the iterable is empty.
	 */
	def static <T, U extends Object & Comparable<? super U>> T maxBy(Iterable<T> iterable, (T) => U function) {
		iterable.maxBy(Ordering::natural, function)
	}

	/**
	 * Returns the maximum element of the this iterable based on the given transformation,
	 * according to the order induced by the specified comparator.
	 *
	 * @throws NoSuchElementException if the iterable is empty.
	 */
	def static <T, U> T maxBy(Iterable<T> iterable, Comparator<? super U> comp, (T) => U function) {
		iterable.iterator.maxBy(comp, function)
	}

	/**
	 * Returns an {@link Optional} containing the maximum element of this iterable based on
	 * the given transformation, according to the <i>natural ordering</i> of the values.
	 *
	 * @throws NullPointerException if the max element is {@code null}; if this is
	 * a possibility, use {@link #maxBy} instead.
	 */
	def static <T, U extends Object & Comparable<? super U>> Optional<T> maxByOptional(Iterable<T> iterable, (T) => U function) {
		iterable.iterator.maxByOptional(function)
	}

	/**
	 * Returns an {@link Optional} containing the maximum element of this iterable based on
	 * the given transformation, according to the order induced by the specified comparator.
	 *
	 * @throws NullPointerException if the max element is {@code null}; if this is
	 * a possibility, use {@link #maxBy} instead.
	 */
	def static <T, U> Optional<T> maxByOptional(Iterable<T> iterable, Comparator<? super U> comp, (T) => U function) {
		iterable.iterator.maxByOptional(comp, function)
	}

	/**
	 * Partitions this iterable into a map of lists according to some discriminator function.
	 * 
	 * <p>The resulting map and lists are unmodifiable.
	 */
	def static <T, K> Map<K, List<T>> groupBy(Iterable<T> iterable, (T) => K function) {
		iterable.iterator.groupBy(function)
	}

	/**
	 * Partitions this iterable into two lists according to a predicate.
	 *
	 * <p>The resulting lists are unmodifiable.
	 *
	 * @return a pair of lists: the first list consists of all elements that satisfy the predicate and
	 * 	the second list consists of all elements that don't. The relative order of the elements in the
	 *	resulting lists is the same as in the original list.
	 */
	def static <T> Pair<List<T>, List<T>> partition(Iterable<T> iterable, (T) => boolean predicate) {
		val listTrue = Lists::newArrayList
		val listFalse = Lists::newArrayList

		for (elem : iterable) {
			if (predicate.apply(elem)) {
				listTrue.add(elem)
			} else {
				listFalse.add(elem)
			}
		}

		listTrue.unmodifiableView -> listFalse.unmodifiableView
	}

	/**
	 * Divides this iterable into unmodifiable sublists of the given size (the final list may be
	 * smaller). For example, grouping an iterable containing {@code [a, b, c, d, e]} with a group
	 * size of 3 yields {@code [[a, b, c], [d, e]]} -- an outer iterable containing two inner lists
	 * of three and two elements, all in the original order.
	 *
	 * <p>Iterators returned by the returned iterable do not support the {@link Iterator#remove()} method.
	 * The returned lists implement {@link RandomAccess}, whether or not the input list does.
	 *
	 * @return an iterable of unmodifiable lists containing the elements of {@code iterable} divided
	 *	into groups
	 * @throws IllegalArgumentException if {@code size} is nonpositive
	 */
	def static <T> Iterable<List<T>> grouped(Iterable<T> iterable, int size) {
		Iterables::partition(iterable, size)
	}

	/**
	 * Groups elements of this iterable in fixed size blocks by passing a "sliding window" over them
	 * (as opposed to partitioning them, as is done in {@link #grouped}.)
	 *
	 * <p>Iterators returned by the returned iterable do not support {@code remove()}.
	 *
	 * @return an iterable of unmodifiable lists of size {@code size}, except the last and the only element
	 * will be truncated if there are fewer elements than {@code size}.
	 */
	def static <T> Iterable<List<T>> sliding(Iterable<T> iterable, int size) {
		checkArgument(size >= 1, "Illegal sliding size: %s", size)
		val FluentIterable<List<T>> result = [| new SlidingItr(iterable.iterator, size) ]
		result
	}

	/**
	 * Takes longest prefix of elements that satisfy a predicate.
	 * <p>For example:
	 * <p>{@code #[1,2,3,4,5,1].takeWhile[it <= 3]} returns {@code #[1,2,3]}
	 *
	 * <p>The source iterator is not polled until necessary. The resulting iterable's iterator does
	 * not support {@code remove()}.
	 */
	def static <T> Iterable<T> takeWhile(Iterable<T> iterable, (T) => boolean predicate) {
		val FluentIterable<T> result = [| new TakeWhileItr(iterable.iterator, predicate)]
		result
	}

	/**
	 * Drops longest prefix of elements that satisfy a predicate.
	 * <p>For example:
	 * <p>{@code #[1,2,3,4,5,1].dropWhile[it <= 3]} returns {@code #[4,5,1]}
	 *
	 * <p>The source iterator is not polled until necessary. The resulting iterable's iterator does
	 * not support {@code remove()}.
	 */
	def static <T> Iterable<T> dropWhile(Iterable<T> iterable, (T) => boolean predicate) {
		val FluentIterable<T> result = [| new DropWhileItr(iterable.iterator, predicate) ]
		result
	}

	/**
	 * Returns an iterable containing the last {@code n} elements of this iterable.
	 *
	 * <p>The source iterator is not polled until necessary. The resulting iterable's iterator does
	 * not support {@code remove()}.
	 */
	def static <T> Iterable<T> takeRight(Iterable<T> iterable, int n) {
		checkArgument(n >= 0, "Cannot take a negative number of elements. Argument 'n' was: %s", n)

		val FluentIterable<T> result = [|
			val size = iterable.size
			if (size <= n) {
				iterable.iterator
			} else {
				Iterables::skip(iterable, size - n).iterator
			}
		]

		result
	}

	/**
	 * Returns an iterable containing all elements of this iterable except the last {@code n} ones.
	 *
	 * <p>The source iterator is not polled until necessary. The resulting iterable's iterator does
	 * not support {@code remove()}.
	 */
	def static <T> Iterable<T> dropRight(Iterable<T> iterable, int n) {
		checkArgument(n >= 0, "Cannot drop a negative number of elements. Argument 'n' was: %s", n)

		val FluentIterable<T> result = [|
			val size = iterable.size
			if (size <= n) {
				Iterators::emptyIterator
			} else {
				Iterables::limit(iterable, size - n).iterator
			}
		]

		result
	}

	/**
	 * Returns an iterable containing the elements greater than or equal to index {@code from} extending
	 * up to (but not including) index {@code until} of this iterable.
	 *
	 * <p>The source iterator is not polled until necessary. The resulting iterable's iterator does
	 * not support {@code remove()}.
	 */
	def static <T> Iterable<T> slice(Iterable<T> iterable, int from, int until) {
		checkArgument(from >= 0, "Argument 'from' was negative: %s", from)
		checkArgument(until >= 0, "Argument 'until' was negative: %s", until)

		if (until <= from) {
			Collections::emptyList
		} else {
			FluentIterable::from(iterable).skip(from).limit(until - from)
		}
	}

	/**
	 * Splits this iterable into two at a given position. Equivalent to
	 * {@code (iterable.take(n) -> iterable.drop(n))}
	 */
	def static <T> Pair<Iterable<T>, Iterable<T>> splitAt(Iterable<T> iterable, int n) {
		Iterables::limit(iterable, n) -> Iterables::skip(iterable, n)
	}

	/**
	 * Splits this iterable into a prefix/suffix pair according to a predicate. Equivalent to
	 * {@code (iterable.takeWhile(predicate) -> iterable.dropWhile(predicate))}
	 */
	def static <T> Pair<Iterable<T>, Iterable<T>> span(Iterable<T> iterable, (T) => boolean predicate) {
		iterable.takeWhile(predicate) -> iterable.dropWhile(predicate)
	}

	/**
	 * Returns an iterable containing cumulative results of applying the operator going left to right.
	 * <p>For example:
	 * <p>{@code (1..5).scan(0)[x, y | x + y]} returns {@code [0, 1, 3, 6, 10, 15]}
	 *
	 * <p>The source iterator is not polled until necessary. The resulting iterable's iterator does
	 * not support {@code remove()}.
	 */
	def static <T, U> Iterable<U> scan(Iterable<T> iterable, U seed, (U, T) => U function) {
		val FluentIterable<U> result = [| new ScanItr(iterable.iterator, seed, function)]
		result
	}

	/**
	 * Finds the index of the first element that satisfies a predicate.
	 *
	 * @return the index of the first element of this iterable that satisfies the predicate,
	 * or {@code -1}, if no elements satisfy the predicate.
	 */
	def static <T> int indexWhere(Iterable<T> iterable, (T) => boolean predicate) {
		iterable.iterator.indexWhere(predicate)
	}

	/**
	 * Finds the index of the first element that satisfies a predicate after or at some start index.
	 *
	 * @return the index {@code >= from} of the first element of this iterable that satisfies the predicate,
	 * or {@code -1}, if no elements satisfy the predicate.
	 */
	def static <T> int indexWhere(Iterable<T> iterable, int from, (T) => boolean predicate) {
		iterable.iterator.indexWhere(from, predicate)
	}

	/**
	 * Finds the index of the last element that satisfies a predicate.
	 *
	 * @return the index of the last element of this iterable that satisfies the predicate,
	 * or {@code -1}, if no elements satisfy the predicate.
	 */
	def static <T> int lastIndexWhere(Iterable<T> iterable, (T) => boolean predicate) {
		iterable.iterator.lastIndexWhere(predicate)
	}

	/**
	 * Finds the index of the last element that satisfies a predicate before or at some end index.
	 *
	 * @return the index {@code <= end} of the last element of this iterable that satisfies the predicate,
	 * or {@code -1}, if no elements satisfy the predicate.
	 */
	def static <T> int lastIndexWhere(Iterable<T> iterable, int end, (T) => boolean predicate) {
		iterable.iterator.lastIndexWhere(end, predicate)
	}

	/**
	 * Returns an iterable which traverses the possible n-element combinations of this iterable.
	 */
	def static <T> Iterable<List<T>> combinations(Iterable<T> iterable, int n) {
		if (n < 0 || n > iterable.size) {
			Collections::emptyList
		} else {
			val FluentIterable<List<T>> result = [| new CombinationsItr(iterable, n) ]
			result
		}
	}

	/**
	 * Sums up the elements of this iterable.
	 */
	@Beta
	def static<T> int sumInt(Iterable<Integer> iterable) {
		iterable.iterator.sumInt
	}

	/**
	 * Sums up the elements of this iterable.
	 */
	@Beta
	def static<T> long sumLong(Iterable<Long> iterable) {
		iterable.iterator.sumLong
	}

	/**
	 * Sums up the elements of this iterable.
	 */
	@Beta
	def static<T> double sumDouble(Iterable<Double> iterable) {
		iterable.iterator.sumDouble
	}
}
