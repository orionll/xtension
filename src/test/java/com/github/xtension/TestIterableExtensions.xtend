package com.github.xtension

import java.util.Collections

import org.junit.Test

import static org.assertj.core.api.Assertions.*

import static extension com.github.xtension.IterableExtensions.*

class TestIterableExtensions {
	@Test
	def void takeRight() {
		val list = #[1, 2, 3]

		assertThat(list.takeRight(0)).isEmpty
		assertThat(list.takeRight(1)).containsExactly(3)
		assertThat(list.takeRight(2)).containsExactly(2, 3)
		assertThat(list.takeRight(3)).containsExactly(1, 2, 3)
		assertThat(list.takeRight(4)).containsExactly(1, 2, 3)
	}

	@Test
	def void sliding() {
		val list = #[1, 2, 3]

		assertThat(list.sliding(1)).containsExactly(#[1], #[2], #[3])
		assertThat(list.sliding(2)).containsExactly(#[1, 2], #[2, 3])
		assertThat(list.sliding(3)).containsExactly(list)
		assertThat(list.sliding(4)).containsExactly(list)
	}

	@Test
	def void combinations() {
		val list = #[1, 2, 3]

		assertThat(list.combinations(-1)).isEmpty
		assertThat(list.combinations(0)).containsOnly(Collections::emptyList)
		assertThat(list.combinations(1)).containsOnly(#[1], #[2], #[3])
		assertThat(list.combinations(2)).containsOnly(#[1, 2], #[2, 3], #[1, 3])
		assertThat(list.combinations(3)).containsOnly(list)
		assertThat(list.combinations(4)).isEmpty
	}
}