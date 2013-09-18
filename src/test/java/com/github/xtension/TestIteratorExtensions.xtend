package com.github.xtension

import org.junit.Test

import static org.assertj.core.api.Assertions.*

import static extension com.github.xtension.IteratorExtensions.*

class TestIteratorExtensions {

	@Test
	def void flatMap() {
		assertThat(#[1,2,3].iterator.flatMap[#[it, it + 1].iterator]).containsExactly(1, 2, 2, 3, 3, 4)
	}
}
