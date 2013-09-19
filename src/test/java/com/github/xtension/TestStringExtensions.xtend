package com.github.xtension

import org.junit.Test

import static org.assertj.core.api.Assertions.*
import static extension com.github.xtension.StringExtensions.*

class TestStringExtensions {

	@Test
	def void map() {
		assertThat("abcd".map[Character::toUpperCase(it)]).isEqualTo("ABCD")
	}
}