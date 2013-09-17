package com.github.xtension

import com.google.common.collect.AbstractIterator
import java.util.Iterator
import org.eclipse.xtext.xbase.lib.Pair

// TODO The returned iterator should support remove() if the
// delegate iterator supports it
package class DropWhileItr<T> extends AbstractIterator<T> {
	// States:
	private static val NEW = 0
	private static val DROPPED = 1
	private static val FIRST_FOUND_RETURNED = 2

	val Iterator<T> delegate
	val (T) => boolean predicate

	var state = NEW
	var Pair<Boolean, T> firstFound

	new(Iterator<T> delegate, (T) => boolean predicate) {
		this.delegate = delegate
		this.predicate = predicate
	}

	override protected computeNext() {
		if (state == NEW) {
			firstFound = delegate.iterateWhile(predicate)
			state = DROPPED
		}

		if (state == DROPPED) {
			if (firstFound.key) {
				state = FIRST_FOUND_RETURNED
				firstFound.value
			} else {
				endOfData
			}
		} else {
			if (delegate.hasNext) {
				delegate.next
			} else {
				endOfData
			}
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
}
