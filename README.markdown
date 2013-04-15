Ucenter authcode
===
在Ruby里实现UCenter的用户信息认证解密。

使用方法
===

```ruby
UC_KEY = "Y426x6Basctda9f94e49h3B6OeofcdX0J8Ua2a37P1M9Jd00he28o3t5ocq707U5"
code = "b384r5HiERJ+kEbb25t9jbtDXULGnCnR++1EK9xlmG74OKkd3hfjC4+dUJePocsJHts2JeO4/Po"
puts UCenter.decode(UC_KEY, code) # => action=test&time=1348015177
```

作者
===
由iceskysl改编自网络代码，再由mvj3重构。

许可证
===
MIT
