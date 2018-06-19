# FMDBManager
## 能做什么

用提供的API可以直接用model生成表。model类名即为表名

### 1. feature 
- [ ] 嵌套数据类型
- [ ] 模型数据类型
- [x] 基础数据类型转换
- [x] 条件搜索
- [x] 模型自动建表



### 2. 存

```oc
SSBDBaseModel *model = [SSBDBaseModel new];
model.age = i;
model.name = [NSString stringWithFormat:@"我是%d",i];
model.timeStamp = @"5891372189";
model.modelArr = @[[SSBDBaseModel new],[SSBDBaseModel new]];
model.strArr = @[@"222",@"3333"];
model.model = [SSBDBaseModel new];
[self.dbManager insertModel:model
                     result:^(FMResultSet *result, 
                                BOOL opIsSuccess) {
                        NSLog(@"%d",opIsSuccess);
                    }];
```
### 3. 取
```oc
[self.dbManager searchItemByThresholdArr:@[@"age<20"]
                                       limit:10
                                    orderKey:@"age"
                                     orderBy:YES
                                      result:^(FMResultSet *result, BOOL opIsSuccess) {
                                          self.dataArr = [NSMutableArray arrayWithArray:[self.dbManager changeFromResult:result]];
                                          success(self.dataArr);
                                      }];
```
