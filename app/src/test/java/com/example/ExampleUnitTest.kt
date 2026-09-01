package com.example

import com.example.ui.screens.formatAndValidateDateInput
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class ExampleUnitTest {

  @Test
  fun testDateFormattingAndMask() {
    val currentYear = 2026

    // Valid date input (09/01/2026)
    val (formatted1, error1, time1) = formatAndValidateDateInput("09012026", currentYear)
    assertEquals("09/01/2026", formatted1)
    assertNull(error1)
    assertNotNull(time1)

    // Incomplete input (0901) -> formats to 09/01/ and gives incomplete error
    val (formatted2, error2, time2) = formatAndValidateDateInput("0901", currentYear)
    assertEquals("09/01/", formatted2)
    assertNotNull(error2)
    assertNull(time2)

    // Past year (2025) should be rejected
    val (formatted3, error3, time3) = formatAndValidateDateInput("15032025", currentYear)
    assertEquals("15/03/2025", formatted3)
    assertTrue(error3?.contains("bulunulan yıl") == true)
    assertNull(time3)

    // Future year (2027) should be accepted
    val (formatted4, error4, time4) = formatAndValidateDateInput("25122027", currentYear)
    assertEquals("25/12/2027", formatted4)
    assertNull(error4)
    assertNotNull(time4)

    // Day > 31 clamped to 31
    val (formatted5, _, _) = formatAndValidateDateInput("39112026", currentYear)
    assertEquals("31/11/2026", formatted5)

    // Month > 12 clamped to 12
    val (formatted6, _, _) = formatAndValidateDateInput("15992026", currentYear)
    assertEquals("15/12/2026", formatted6)
  }
}
