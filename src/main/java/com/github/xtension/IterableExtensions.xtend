package com.github.xtension

import java.util.Collections
import java.util.Comparator
import java.util.Iterator
import java.util.List
import java.util.Map
import com.google.common.annotations.Beta
import com.google.common.base.Optional
import com.google.common.collect.AbstractIterator
import com.google.common.collect.FluentIterable
import com.google.common.collect.Iterables
import com.google.common.collect.Iterators
import com.google.common.collect.Lists
import com.google.common.collect.Maps
import com.google.common.collect.Ordering
import com.google.common.math.IntMath
import com.google.common.math.LongMath
import org.eclipse.xtext.xbase.lib.internal.BooleanFunctionDelegate

import static extension com.github.xtension.MapExtensions.*

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
	 * is matched in this fluent iterable, a {@link NullPointerException} will be thrown.
	 */
	def static <T> Optional<T> findFirstOptional(Iterable<T> iterable, (T) => boolean predicate) {
		Iterables::tryFind(iterable, new BooleanFunctionDelegate<T>(predicate))
	}

	/**
	 * Builds a new iterable by applying a function to all elements of this iterable
	 * and using the elements of the resulting iterables.
	 * 
	 * <p>For example:
	 * 
	 * <p>{@code val words = lines.flatMap[split("\\W+").toList]}
	 */
	def static <T, U> Iterable<U> flatMap(Iterable<T> iterable, (T) => Iterable<? extends U> function) {
		iterable.map(function).flatten
	}

	/**
	 * Counts the number of elements in this iterable which satisfy a predicate.
	 */
	def static <T> int count(Iterable<T> iterable, (T) => boolean predicate) {
		var count = 0
		for (element : iterable) {
			if (predicate.apply(element)) {
				count = count + 1
			}
		}

		count
	}

	/**
	 * Produces the range of all indices of this iterable.
	 *
	 *  @return	a range from 0 to one less than the size of this iterable.
	 */
	def static ExclusiveRange indices(Iterable<?> iterable) {
		0 ..< iterable.size
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
	 * Produces a new iterable which contains all elements of this iterable and also all elements of
	 * a given iterable. The source iterators are not polled until necessary.
	 *
	 * <p>The returned iterable's iterator supports {@code remove()} when the
	 * corresponding input iterator supports it.
	 */
	def static <T> Iterable<T> union(Iterable<? extends T> a, Iterable<? extends T> b) {
		Iterables::concat(a, b)
	}

	/**
	 * Returns an iterable formed from this iterable and another iterable by combining
	 * corresponding elements in pairs. If one of the two collections is longer than the other,
	 * its remaining elements are ignored. The source iterators are not polled until necessary.
	 * 
	 * <p>The resulting iterable's iterator does not support {@code remove()}.
	 */
	def static <T, U> Iterable<Pair<T, U>> zip(Iterable<T> a, Iterable<U> b) {
		val FluentIterable<Pair<T, U>> result = [|
			val iterator1 = a.iterator
			val iterator2 = b.iterator

			val AbstractIterator<Pair<T, U>> iterator = [|
				if (iterator1.hasNext && iterator2.hasNext) {
					iterator1.next -> iterator2.next
				} else { 
					self.endOfData
				}
			]

			iterator
		]
		
		result
	}

	/**
	 * Converts this iterable of pairs into two lists of the first and second
	 * half of each pair.
	 * 
	 * <p>The resulting lists are unmodifiable.
	 */
	def static <T, U> Pair<List<T>, List<U>> unzip(Iterable<Pair<T, U>> iterable) {
		val size = iterable.size
		val List<T> a = Lists::newArrayListWithCapacity(size)
		val List<U> b = Lists::newArrayListWithCapacity(size)

		for (Pair<T, U> pair : iterable) {
			a.add(pair.key)
			b.add(pair.value)
		}

		a.unmodifiableView -> b.unmodifiableView
	}
	
	/**
	 * Zips this iterable with its indices.
	 * 
	 * <p>The resulting iterable's iterator does not support {@code remove()}.
	 */
	def static <T> Iterable<Pair<T, Integer>> zipWithIndex(Iterable<T> iterable) {
		iterable.zip(iterable.indices)
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
	 * Returns the minimum element of the given iterable, according to the order induced by
	 * the specified comparator.
	 * 
	 * @throws NoSuchElementException if the iterable is empty.
	 */
	def static <T> T min(Iterable<T> iterable, Comparator<? super T> comp) {
		val i = iterable.iterator
		var min = i.next

		while (i.hasNext) {
			val next = i.next
			if (comp.compare(next, min) < 0) {
				min = next
			}
		}

		min
	}

	/**
	 * Returns the minimum element of the given iterable based on the given {@code transformation},
	 * according to the <i>natural ordering</i> of the values.
	 * 
	 * @throws NoSuchElementException if the iterable is empty.
	 */
	def static <T, U extends Object & Comparable<? super U>> T minBy(Iterable<T> iterable, (T) => U function) {
		iterable.minBy(Ordering::natural, function)
	}

	/**
	 * Returns the minimum element of the given iterable based on the given {@code transformation},
	 * according to the order induced by the specified comparator.
	 * 
	 * @throws NoSuchElementException if the iterable is empty.
	 */
	def static <T, U> T minBy(Iterable<T> iterable, Comparator<? super U> comp, (T) => U function) {
		val i = iterable.iterator
		var min = i.next

		while (i.hasNext) {
			val next = i.next
			if (comp.compare(function.apply(next), function.apply(min)) < 0) {
				min = next
			}
		}

		min
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
	 * Returns the maximum element of the given iterable, according to the order induced by
	 * the specified comparator.
	 * 
	 * @throws NoSuchElementException if the iterable is empty.
	 */
	def static <T> T max(Iterable<T> iterable, Comparator<? super T> comp) {
		val i = iterable.iterator
		var max = i.next

		while (i.hasNext) {
			val next = i.next
			if (comp.compare(next, max) > 0) {
				max = next
			}
		}

		max
	}

	/**
	 * Returns the maximum element of the given iterable based on the given {@code transformation},
	 * according to the <i>natural ordering</i> of the values.
	 * 
	 * @throws NoSuchElementException if the iterable is empty.
	 */
	def static <T, U extends Object & Comparable<? super U>> T maxBy(Iterable<T> iterable, (T) => U function) {
		iterable.maxBy(Ordering::natural, function)
	}

	/**
	 * Returns the maximum element of the given iterable based on the given {@code transformation},
	 * according to the order induced by the specified comparator.
	 * 
	 * @throws NoSuchElementException if the iterable is empty.
	 */
	def static <T, U> T maxBy(Iterable<T> iterable, Comparator<? super U> comp, (T) => U function) {
		val i = iterable.iterator
		var max = i.next

		while (i.hasNext) {
			val next = i.next
			if (comp.compare(function.apply(next), function.apply(max)) > 0) {
				max = next
			}
		}

		max
	}

	/**
	 * Partitions this iterable into a map of lists according to some discriminator function.
	 * 
	 * <p>The resulting map and lists are unmodifiable.
	 */
	def static <T, K> Map<K, List<T>> groupBy(Iterable<T> iterable, (T) => K function) {
		val map = Maps::<K, List<T>>newHashMap

		for (elem : iterable) {
			val key = function.apply(elem)
			map.getOrElseUpdate(key, Lists::newArrayList).add(elem)
		}

		for (key : map.keySet) {
			map.put(key, map.get(key).unmodifiableView)
		}

		map.unmodifiableView
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
	 * Takes longest prefix of elements that satisfy a predicate.
	 * <p>For example:
	 * <p>{@code #[1,2,3,4,5,1].takeWhile[it <= 3]} returns {@code #[1,2,3]}
	 *
	 * <p>The source iterator is not polled until necessary. The resulting iterable's iterator does
	 * not support {@code remove()}.
	 */
	def static <T> Iterable<T> takeWhile(Iterable<T> iterable, (T) => boolean predicate) {
		val FluentIterable<T> result = [|
			val delegate = iterable.iterator

			// TODO The returned iterator should support remove() if the
			// delegate iterator supports it
			val AbstractIterator<T> iterator = [|
				if (delegate.hasNext) {
					val elem = delegate.next
					if (predicate.apply(elem)) {
						elem
					} else {
						self.endOfData
					}
				} else {
					self.endOfData
				}
			]

			iterator
		]

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
		val FluentIterable<T> result = [|
			val delegate = iterable.iterator

			val firstFound = delegate.iterateWhile(predicate)

			// TODO The returned iterator should support remove() if the
			// delegate iterator supports it
			if (firstFound.key) {
				val AbstractIterator<T> iterator = [|
					if (delegate.hasNext) {
						delegate.next
					} else {
						self.endOfData
					}
				]

				Iterators::concat(Iterators::singletonIterator(firstFound.value), iterator)
			} else {
				Iterators::emptyIterator
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
		val lo = Math::max(from, 0)

		if (until <= lo) {
			Collections::emptyList
		} else {
			iterable.drop(lo).take(until - lo)
		}
	}

	/**
	 * Iterates while a predicate is satisfied.
	 *
	 * @return {@code (true -> elem)}, where {@code elem} is the first element that does not satisfy the predicate,
	 * or {@code (false -> null)}, if all elements satisfy the predicate.
	 */
	private def static <T> Pair<Boolean, T> iterateWhile(Iterator<T> iterator, (T) => boolean predicate) {
		while (iterator.hasNext) {
			val next = iterator.next
			if (!predicate.apply(next)) {
				return true -> next
			}
		}

		false -> null
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
		val FluentIterable<U> result = [|
			val delegate = iterable.iterator

			// An array is created here because closures can not use var
			val Object[] prevValue = newArrayOfSize(1)
			prevValue.set(0, seed)

			val AbstractIterator<U> iterator = [|
				if (delegate.hasNext) {
					val nextValue = function.apply(prevValue.get(0) as U, delegate.next)
					prevValue.set(0, nextValue)
					nextValue
				} else {
					self.endOfData
				}
			]

			Iterators::concat(Iterators::singletonIterator(seed), iterator)
		]

		result
	}

	/**
	 * Finds the index of the first element that satisfies a predicate.
	 *
	 * @return the index of the first element of this iterable that satisfies the predicate,
	 * or {@code -1}, if no elements satisfy the predicate.
	 */
	def static <T> int indexWhere(Iterable<T> iterable, (T) => boolean predicate) {
		iterable.indexWhere(0, predicate)
	}

	/**
	 * Finds the index of the first element that satisfies a predicate after or at some start index.
	 *
	 * @return the index {@code >= from} of the first element of this iterable that satisfies the predicate,
	 * or {@code -1}, if no elements satisfy the predicate.
	 */
	def static <T> int indexWhere(Iterable<T> iterable, int from, (T) => boolean predicate) {

		val drop = if (from == 0) iterable else iterable.drop(from)
		var i = from

		for (T elem : drop) {
			if (predicate.apply(elem)) {
				return i
			}

			i = i + 1
		}

		return -1
	}

	/**
	 * Finds the index of the last element that satisfies a predicate.
	 *
	 * @return the index of the last element of this iterable that satisfies the predicate,
	 * or {@code -1}, if no elements satisfy the predicate.
	 */
	def static <T> int lastIndexWhere(Iterable<T> iterable, (T) => boolean predicate) {
		iterable.lastIndexWhere(iterable.size - 1, predicate)
	}

	/**
	 * Finds the index of the last element that satisfies a predicate before or at some end index.
	 *
	 * @return the index {@code <= end} of the last element of this iterable that satisfies the predicate,
	 * or {@code -1}, if no elements satisfy the predicate.
	 */
	def static <T> int lastIndexWhere(Iterable<T> iterable, int end, (T) => boolean predicate) {
		var i = 0
		var last = -1

		for (T elem : iterable) {
			if (i > end) {
				return last
			}
			if (predicate.apply(elem)) {
				last = i
			}

			i = i + 1
		}

		last
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
		var sum = 0
		for (int i : iterable) {
			sum = IntMath::checkedAdd(sum, i)
		}

		sum
	}

	/**
	 * Sums up the elements of this iterable.
	 */
	@Beta
	def static<T> long sumLong(Iterable<Long> iterable) {
		var sum = 0L
		for (long i : iterable) {
			sum = LongMath::checkedAdd(sum, i)
		}

		sum
	}

	/**
	 * Sums up the elements of this iterable.
	 */
	@Beta
	def static<T> double sumDouble(Iterable<Double> iterable) {
		var sum = 0.0
		for (double i : iterable) {
			sum = sum + i
		}

		sum
	}
}
