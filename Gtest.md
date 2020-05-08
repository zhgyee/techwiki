# Introduction #

Add your content here.


# Details #

通过操作符<<将一些自定义的信息输出，通常，这对于调试或是对一些检查点的补充说明来说，非常有用
```
for (int i = 0; i < x.size(); ++i)
{
    EXPECT_EQ(x[i], y[i]) << "Vectors x and y differ at index " << i;
}
```

# 事件 #
  1. 全局事件
  1. TestSuit 事件
  1. TestCase 事件

# 参数化 #
```
class IsPrimeParamTest : public::testing::TestWithParam<int>
{

};
TEST_P(IsPrimeParamTest, HandleTrueReturn)
{
    int n =  GetParam();
    EXPECT_TRUE(IsPrime(n));
}
INSTANTIATE_TEST_CASE_P(TrueReturn, IsPrimeParamTest, testing::Values(3, 5, 11, 23, 17));
```

#gtest运行时指定命令行参数
refer webrtc/video/replay.cc
```
#include "gflags/gflags.h"
//define flags
DEFINE_int32(payload_type, 0, "Payload type");
static int PayloadType() { return static_cast<int>(FLAGS_payload_type); }
//entry point
int main(int argc, char* argv[]) {
  ::testing::InitGoogleTest(&argc, argv);
  google::ParseCommandLineFlags(&argc, &argv, true);

  webrtc::test::RunTest(webrtc::RtpReplay);
  return 0;
}

```
