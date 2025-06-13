#include <gtest/gtest.h>
#include "util.hpp"

TEST(UtilTest, Greet) {
    EXPECT_EQ(greet("GTest"), "Hello, GTest!");
}
