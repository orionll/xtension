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
	def void dropRight() {
		val list = #[1, 2, 3]

		assertThat(list.dropRight(0)).containsExactly(1, 2, 3)
		assertThat(list.dropRight(1)).containsExactly(1, 2)
		assertThat(list.dropRight(2)).containsExactly(1)
		assertThat(list.dropRight(3)).isEmpty
		assertThat(list.dropRight(4)).isEmpty
	}

	@Test
	def void takeWhile() {
		val list = #[1, 2, 3]

		assertThat(list.takeWhile[it < 1]).isEmpty
		assertThat(list.takeWhile[it < 2]).containsExactly(1)
		assertThat(list.takeWhile[it < 3]).containsExactly(1, 2)
		assertThat(list.takeWhile[it < 4]).containsExactly(1, 2, 3)
	}

	@Test
	def void dropWhile() {
		val list = #[1, 2, 3]

		assertThat(list.dropWhile[it < 1]).containsExactly(1, 2, 3)
		assertThat(list.dropWhile[it < 2]).containsExactly(2, 3)
		assertThat(list.dropWhile[it < 3]).containsExactly(3)
		assertThat(list.dropWhile[it < 4]).isEmpty
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
	def void scan() {
		assertThat(#[].scan(0, [ int prev, int next | prev + next])).containsExactly(0)
		assertThat(#[1, 2, 3].scan(0, [ prev, next | prev + next])).containsExactly(0, 1, 3, 6)
	}

	@Test
	def void indices() {
		assertThat(#[1, 2, 3].indices).containsExactly(0, 1, 2)
		assertThat(#[].indices).isEmpty
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

	@Test
	def void zip() {
		assertThat(#[1,2,3].zip(#['a','b','c'])[ a, b | a + b ]).containsExactly('1a', '2b', '3c')
	}

	@Test
	def void grouped() {
		assertThat(#[1, 2, 3].grouped(2)).containsExactly(#[1, 2], #[3])
	}

	@Test
	def void groupBy() {
		val map = #[1, 2, 3].groupBy[it % 2 == 0]
		assertThat(map).hasSize(2)
		assertThat(map.get(true)).containsExactly(2)
		assertThat(map.get(false)).containsExactly(1, 3)
	}

	@Test
	def void min() {
		assertThat(#[1, 2, 0].min).isEqualTo(0)
	}

	@Test
	def void minBy() {
		assertThat(#[1, 2, 0].minBy[-it]).isEqualTo(2)
	}

	@Test
	def void max() {
		assertThat(#[1, 2, 0].max).isEqualTo(2)
	}

	@Test
	def void maxBy() {
		assertThat(#[1, 2, 3].maxBy[-it]).isEqualTo(1)
	}

	@Test
	def void sumInt() {
		assertThat(#[1,2,3].sumInt).isEqualTo(6)
	}

	@Test
	def void sumLong() {
		assertThat(#[1L,2L,3L].sumLong).isEqualTo(6L)
	}

	@Test
	def void sumDouble() {
		assertThat(#[1.0,2.0,3.0].sumDouble).isEqualTo(6.0, offset(1e-10))
	}
}