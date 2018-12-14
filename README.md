# XWDatabase

[![CI Status](https://img.shields.io/travis/qxuewei@yeah.net/XWDatabase.svg?style=flat)](https://travis-ci.org/qxuewei@yeah.net/XWDatabase)
[![Version](https://img.shields.io/cocoapods/v/XWDatabase.svg?style=flat)](https://cocoapods.org/pods/XWDatabase)
[![License](https://img.shields.io/cocoapods/l/XWDatabase.svg?style=flat)](https://cocoapods.org/pods/XWDatabase)
[![Platform](https://img.shields.io/cocoapods/p/XWDatabase.svg?style=flat)](https://cocoapods.org/pods/XWDatabase)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

XWDatabase is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'XWDatabase'
```

## Author

qxuewei@yeah.net, qiuxuewei@peiwo.cn


## Introduce

##### [XWDatabase](https://github.com/qxuewei/XWDatabase) 将数据库操作简化到难以想象的程度，你甚至不需要知道数据库的存在，当然更不需要写 SQL 语句，你只需要直接操作模型即可对模型进行增删改查的操作，她会根据模型动态在数据库中创建以当前模型类名为名称的数据库表，当然你也可以自定义表名；她会根据模型的成员变量和成员变量的类型动态进行字段的设计，有多少成员变量，表中自然就会有多少字段与其对应，当然，你也可以忽略其中的某些你不想存储的成员变量，也可以自定义字段的名称；如果哪天模型的字段变化了，她会自动进行表中原有字段的更新，而且无论原表中有多少数据，都会一条不落的迁移到新表中；她的API简单到只有一行代码，你无需关注数据库的开启和关闭，一行代码实现增删改查和数据迁移； 你甚至可以在任何线程中调用她的API，她一定是线程安全的，不会出现多线程访问同一个数据库和死锁的问题；数据操作是耗时操作，所以你无需手动开启异步线程操作数据库操作，她会统一在一个保活的异步线程中执行；她支持存储常见的数据类型（int,long,signed,float,double,NSInteger,CGFloat,BOOL,NSString,NSMutableString,NSNumber,NSArray,NSMutableArray,NSDictionary,NSMutableDictionary,NSData,NSMutableData,UIImage,NSDate,NSURL,NSRange,CGRect,CGSize,CGPoint,自定义对象 等的存储.）； 她还对二进制文件的存储做了优化，比如同一张图片表中所有数据都持有这张图片对象，她在数据库中只会有一份拷贝，竭尽她所能优化存储空间。 笔锋一转，V1.0 版本会存在很多不足，希望各位前辈和大牛多多指正，多提 `issues`


<!-- more -->

下面简述一下此库的一些设计思路和使用方法

### 使用

#### 一、增

##### 1.保存一个模型

```
- (void)saveOnePerson
{
    XWPerson *person = [XWPerson testPerson:2];
    [XWDatabase saveModel:person completion:^(BOOL isSuccess) {

    }];
}
```
实例化一个对象， 调用 `saveModel` 方法。

##### 2.保存多个模型

```
- (void)saveModels
{
    NSMutableArray *persons = [[NSMutableArray alloc] init];
    for (int i = 0; i < 1000; i++) {
        [persons addObject:[XWPerson testPerson:i]];
    }
    [XWDatabase saveModels:persons completion:^(BOOL isSuccess) {
        
    }];
}
```
实例化一堆对象， 调用 `saveModels` 方法。

#### 二、删

##### 1.删除一个模型

```
- (void)deleteModel
{
    XWPerson *person = [XWPerson new];
    person.cardID = @"1"; /// 指定想删除的主键（或联合主键）
    [XWDatabase deleteModel:person completion:^(BOOL isSuccess) {
        
    }];
}
```
实例化一个对象，为主键赋值（得知道删的是哪个，让她猜，臣妾做不到）， 调用 `deleteModel` 方法。

##### 2.删除此模型存储的所有数据

```
- (void)clearModel
{
    [XWDatabase clearModel:XWPerson.class completion:^(BOOL isSuccess) {

    }];
}
```
调用 `clearModel` 方法，传入想删除的模型类

##### 3.选择性删除此模型存储的数据

```
/// 删除 age > 50 的数据
- (void)clearModel
{
    [XWDatabase clearModel:XWPerson.class condition:@"age > '50'" completion:^(BOOL isSuccess) {
        
    }];
}
```
调用 `clearModel` 方法，传入想删除的模型类和条件


#### 三、改

##### 1.更新某模型某个成员变量 （选择性更新）

```
/// 改名
- (void)updateModel
{
    XWPerson *person = [XWPerson new];
    person.cardID = @"2";
    person.name = @"新名字";
    
    /// 自定义成员变量更新
    [XWDatabase updateModel:person updatePropertys:@[@"name"] completion:^(BOOL isSuccess) {
        
   }];
    
}
```
实例化一个对象，为主键和有变化的成员变量赋值， 调用 `updateModel` 方法，传入想更新的成员变量名称。

##### 2.更新某模型所有数据 （全量更新）

```
/// 根据传入的模型整体更新
- (void)updateModel
{
    XWPerson *person = [XWPerson new];
    person.cardID = @"2";
    person.name = @"新名字";
    person.girls = @[@"小妹",@"校花",@"小baby"];
    
    /// 整个模型更新
    [XWDatabase saveModel:person completion:^(BOOL isSuccess) {
        
    }];
    
}
```
实例化一个对象， 调用 `updateModel` 方法，传入想更新的模型。

#### 四、查

##### 1.根据主键查询模型 

```
- (void)getOnePerson
{
    XWPerson *person = [XWPerson new];
    person.cardID = @"81";
    [XWDatabase getModel:person completion:^(XWPerson * obj) {
        
    }];
}
```
实例化一个对象，为主键赋值， 调用 `getModel` 方法。

##### 2.查询数据库中所有该模型存储的数据

```
- (void)getModels
{
    [XWDatabase getModels:XWPerson.class completion:^(NSArray * _Nullable objs) {
        
        
    }];
}
```
调用 `getModels` 方法，传入模型类

##### 3.查询数据库中所有该模型存储的数据 - 按某成员变量排序

```
/// 获取数据库中所有该模型存储的数据 - 按 age 字段降序排列
- (void)getModelsSortAge
{
    [XWDatabase getModels:XWPerson.class sortColumn:@"age" isOrderDesc:YES completion:^(NSArray * _Nullable objs) {
        
    }];
}
```
调用 `getModels` 方法，传入模型类和要排序的字段

##### 4.查询数据库中所有该模型存储的数据 - 自定义查询条件

```
/// 获取数据库中所有该模型存储的数据 - 自定义查找条件 (例如模糊查询 name 含 学伟 的数据)
- (void)getModelsCondition
{
    [XWDatabase getModels:XWPerson.class condition:@"name like '%学伟'" completion:^(NSArray * _Nullable objs) {
        
    }];
}
```
调用 `getModels` 方法，传入模型类和查询的条件

##### 5.查询数据库中所有该模型存储的数据 - 自定义查询条件并且可按照某字段排序

```
/// 获取数据库中所有该模型存储的数据 - 自定义查找条件可排序 (例如模糊查询 name 含 学伟 的数据, 并且按 age 升序排序)
- (void)getModelsConditionSort
{
    [XWDatabase getModels:XWPerson.class sortColumn:@"age" isOrderDesc:NO condition:@"name like '%学伟'" completion:^(NSArray * _Nullable objs) {
        
    }];
}
```
调用 `getModels` 方法，传入模型类和查询的条件和排序的成员变量名称

#### 五、数据迁移

##### 模型中成员变量发生变化，动态进行数据迁移

```
+ (void)initialize 
+ {
    [XWDatabase updateTable:self completion:^(BOOL isSuccess) {
        
    }];
```
在模型对象的 `initialize` 方法中 调用 `updateTable` 方法。之所以在 `initialize` 方法中调用是保证用户无感知的情况下在操作此模型进行数据操作时自动更新。


以上就是 `XWDatabase` V1.0 版本的所有功能示例。谢谢！

下面介绍一些使用规范和功能扩展。

#### 六 、`XWDatabaseModelProtocol` 协议

```
/**
 主键 不可更改/唯一性
 
 @return 主键的属性名
 */
+ (NSString *)xw_primaryKey;

/**
 联合主键成员变量数组 (多个属性共同定义主键) - 优先级大于 'xw_primaryKey'

 @return 联合主键成员变量数组
 */
+ (NSArray < NSString * > *)xw_unionPrimaryKey;

/**
 自定义对象映射  (key: 成员变量名称 value: 对象类)

 @return 自定义对象映射
 */
+ (NSDictionary *)xw_customModelMapping;

/**
 忽略不保存数据库的属性
 
 @return 忽略的属性名数组
 */
+ (NSSet <NSString *>*)xw_ignoreColumnNames;

/**
 自定义字段名映射表 (默认成员变量即变量名, 可自定义字段名 key: 成员变量(属性)名称  value: 自定义数据库表字段名)

 @return 自定义字段名映射表
 */
+ (NSDictionary *)xw_customColumnMapping;

/**
 自定义表名 (默认属性类名)

 @return 自定义表名
 */
+ (NSString *)xw_customTableName;

```

当模型遵守 `XWDatabaseModelProtocol` 协议并选择性实现其中某些方法时她便会更好的为您服务。当然 主键 `xw_primaryKey`（或联合主键 `xw_unionPrimaryKey` ）是查询和更新必须要实现的方法。

如果模型中成员变量存在其他的自定义模型，那其他的自定义模型需要遵从 `NSCoding` 协议并实现 `initWithCoder` 和 `encodeWithCoder` 方法。 [XWDatabase](https://github.com/qxuewei/XWDatabase) 中的 `NSObject+XWModel` 提供了一个宏可以快速使自定义对象具备归解档的功能 `XWCodingImplementation`

### 设计思路
1. 根据 `runtime` 获取对象成员变量名称和类型生成 建表 `SQL` 语句
2. 根据当前对象成员变量名称和原有数据库表中字段排序后进行比较，有差异进行数据迁移
3. 根据模型动态生成 `SQL` 语句 
4. 利用事务进行大数据量的操作
5. 创建一个保活的子线程（使异步线程的 `Runloop` 保持活跃）进行数据库操作，使用主线程队列保证数据操作的同步
6. 数据库底层封装自 [FMDB](https://github.com/ccgus/fmdb/)
7. 创建一个单独存放图片二进制的库存储二进制文件。真实表中存储 二进制 文件的 `hash` 值已达到数据重用。


此库支持 `CocoaPod` 集成:

```
pod 'XWDatabase'
```


作者：极客学伟
博客：<https://blog.csdn.net/qxuewei/>


## License

XWDatabase is available under the MIT license. See the LICENSE file for more info.


