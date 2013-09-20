package com.github.xtension

import com.google.common.collect.AbstractIterator
import java.util.Iterator

package class IndicesItr extends AbstractIterator<Integer> {
	val Iterator<?> delegate
	var i = -1

	new(Iterator<?> delegate) {
		if (delegate === null) {
			throw new IllegalArgumentException("Null delegate")
		}
		this.delegate = delegate
	}

	override protected Integer computeNext() {
		i = i + 1
		if (delegate.hasNext) {
			delegate.next
			Integer::valueOf(i) // NPE is thrown is use simply i
		} else {
			endOfData
		}
	}
}