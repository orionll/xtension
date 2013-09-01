package com.github.xtension

import java.util.ArrayDeque
import java.util.ArrayList
import java.util.Iterator
import java.util.List

import static com.google.common.base.Preconditions.*

import com.google.common.collect.AbstractIterator

package class SlidingItr<B> extends AbstractIterator<List<B>> {

	val Iterator<B> self
	val int size
	var buffer = new ArrayDeque<B>
	var filled = false

	new(Iterator<B> self, int size) {
		checkArgument(size >= 1, "Illegal sliding size: %s", size)
		this.self = self
		this.size = size
	}

	private def void fill() {
		if (!self.hasNext) {
			return
		}

		if (buffer.isEmpty) {
			// the first time we grab size
			var i = 0
			while (self.hasNext && i < size) {
				buffer += self.next
				i = i + 1
			}
		} else {
			buffer.removeFirst
			buffer.addLast(self.next)
		}

		filled = true
	}

	override computeNext() {
		if (!filled) {
			fill()
		}

		if (!filled) {
			return endOfData()
		}

		filled = false

		(new ArrayList(buffer)).unmodifiableView
	}
}