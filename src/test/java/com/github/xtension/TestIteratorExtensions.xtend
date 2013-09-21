package com.github.xtension

import org.junit.Test

import static org.assertj.core.api.Assertions.*

import static extension com.github.xtension.IteratorExtensions.*

class TestIteratorExtensions {

	@Test
	def void lastOptional() {
		org.assertj.guava.api.Assertions::assertThat(#[1,2,3].iterator.lastOptional).contains(3)
		org.assertj.guava.api.Assertions::assertThat(#[].iterator.lastOptional).isAbsent
	}

	@Test
	def void flatMap() {
		assertThat(#[1,2,3].iterator.flatMap[#[it, it + 1].iterator]).containsExactly(1, 2, 2, 3, 3, 4)
	}

	@Test
	def void slice() {
		assertThat(#[1,2,3].iterator.slice(1, 2)).containsExactly(2)
		assertThat(#[1,2,3].iterator.slice(1, 3)).containsExactly(2, 3)
		assertThat(#[1,2,3].iterator.slice(1, 4)).containsExactly(2, 3)
		assertThat(#[1,2,3].iterator.slice(4, 5)).isEmpty
	}
}
