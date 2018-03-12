
# 导入项目 #

项目是由eclipse来编写的，我使用的开发环境是Idea，那么就需要将eclipse项目导入进去Idea中。要想项目能够启动起来。是这样干的：

导入eclipse的项目
![](http://images2017.cnblogs.com/blog/1053130/201710/1053130-20171018190152474-659213402.png)


添加对应的Web Model，添加完毕之后，默认会提示要我们创建对应的Facts的。

![](http://images2017.cnblogs.com/blog/1053130/201710/1053130-20171018190324224-810968195.png)

接着修改Facets中标出的值，因为我们手动创建的话，指向的是Idea中的web目录的。可是项目是用eclipse编写的，因此要改成是WebRoot对应的文件！

![](http://images2017.cnblogs.com/blog/1053130/201710/1053130-20171018190506115-1183077789.png)



接着配置Tomcat，就基本可以让eclipse中的项目在Idea环境下运行了。

- 当然了、**数据库是需要自己配置与eclipse中的环境一模一样的**。

# 主菜单跳转JSP页面 #

在主菜单页面上有很多的URL跳转到不同的JSP页面。

- **我们的JSP可能是放在WEB-INF下的，是无法直接获取的。因此需要Controller进行转发**
- **如果为每个超链接都写一个Controller方法的话，那么会有点麻烦！**

![](http://images2017.cnblogs.com/blog/1053130/201710/1053130-20171018192020943-584385076.png)

这些超链接是不同的模块下的。**但是我们可以使用BaseAction对他们进行统一管理起来**！

- **这里使用到了@PathVariable这么一个注解。变量从@RequestMapping中的参数来拿。**
- **所有的主菜单超链接都通过我们的BaseAction来进行处理**！

```java

		//方法参数folder通过@PathVariable指定其值可以从@RequestMapping的{folder}获取，同理file也一样

		@RequestMapping("/goURL/{folder}/{file}")
		public String goURL(@PathVariable String folder,@PathVariable String file) {
			return "forward:/WEB-INF/"+folder+"/"+file+".jsp";
		}
```


**我们常常在跳转页面之前都要查询数据库的数据的，那如果是这样设计的话，我们可以将常用数据放在application域对象中，或者使用ajax来进行获取数据！**

# 分页对象设计 #

之前我们做的分页对象就仅仅**把我们分页所用到的基本属性封装起来**。如果页面上有查询条件的话，我们**另外创建了一个查询对象**。

**当时候创建出来的查询对象的属性是根据页面上的条件来编写的。这样做得不够好，没有通用性！**

这次看见这个项目的Page设计就非常通用了，虽然把查询条件都放在了Page对象中，但我感觉比之前那个好！

- **由于它使用了easyUI，该组件会自动计算出总页数，所以在Page对象设计的时候就没有对应的总页数属性了。如果我们不是用easyUI的话，我们补上即可！**

```java

public class Page<T> implements Serializable {


	private static final long serialVersionUID = 337297181251071639L;
	
	private Integer page;//当前页
	private Integer rows;//页大小
	private Integer totalRecord;// 总记录 数

	private List<T> list;//页面数据列表

	private String keyWord;//查询关键字

	private T paramEntity;//多条件查询

	private Integer start;//需要这里处理

	//因为它用的是easyUI，所以没有设置总页数的属性，使用Map集合来替代了。
	private Map<String, Object> pageMap = new HashMap<String, Object>() ;
	public Map<String, Object> getPageMap() {
		return pageMap;
	}
	/*public void setPageMap(Map<String, Object> pageMap) {
		this.pageMap = pageMap;
	}*/
	public T getParamEntity() {
		return paramEntity;
	}
	public void setParamEntity(T paramEntity) {
		this.paramEntity = paramEntity;
	}
	public Integer getPage() {
		return page;
	}
	public void setPage(Integer page) {
		this.page = page;
	}
	public Integer getRows() {
		return rows;
	}
	public void setRows(Integer rows) {
		this.rows = rows;
	}
	/*public Integer getTotalRecord() {
		return totalRecord;
	}*/
	public void setTotalRecord(Integer totalRecord) {
		pageMap.put("total", totalRecord);
		this.totalRecord = totalRecord;
	}
/*	public List<T> getList() {
		return list;
	}*/
	public void setList(List<T> list) {
		pageMap.put("rows", list);
		this.list = list;
	}
	public String getKeyWord() {
		return keyWord;
	}
	public void setKeyWord(String keyWord) {
		this.keyWord = keyWord;
	}
	public Integer getStart() {
		this.start = (page-1)*rows;
		return start;
	}
	public void setStart(Integer start) {
		this.start = start;
	}
	@Override
	public String toString() {
		return "Page [page=" + page + ", rows=" + rows + ", totalRecord="
				+ totalRecord + ", list=" + list + ", keyWord=" + keyWord
				+ ", paramEntity=" + paramEntity + ", start=" + start + "]";
	}
}
```

- 使用了泛型对象的话，我们就可以完成多条件查询了！**这个泛型对象就相当于我们的查询对象！**


----------

# 抽取Service层 #

之前我们也抽取过Service层的代码，当时候也觉得用得十分巧妙：

- **在baseService中提供一个setBaseDao()的方法**
- **具体serviceImpl使用具体Dao的时候，通过setDao来进行注入对应的Dao对象，同时调用父类的setDao方法，让BaseService的BaseDao能够实现实例化！**


然而，这次看到的baseService就用得更加巧妙了，并且设计得更加好！

如下代码：

```java


package cn.itcast.scm.service.impl;

import java.lang.reflect.Field;
import java.lang.reflect.ParameterizedType;

import javax.annotation.PostConstruct;

import org.springframework.beans.factory.annotation.Autowired;

import cn.itcast.scm.dao.AccountMapper;
import cn.itcast.scm.dao.AccountRecordsMapper;
import cn.itcast.scm.dao.BaseMapper;
import cn.itcast.scm.dao.BuyOrderDetailMapper;
import cn.itcast.scm.dao.BuyOrderMapper;
import cn.itcast.scm.dao.GoodsMapper;
import cn.itcast.scm.dao.SupplierMapper;
import cn.itcast.scm.dao.SysParamMapper;
import cn.itcast.scm.entity.Page;
import cn.itcast.scm.service.BaseService;

public class BaseServiceImpl<T> implements BaseService<T> {
	protected  BaseMapper<T> baseMapper;
	
	@Autowired
	protected  SupplierMapper supplierMapper;
	
	@Autowired
	protected  AccountMapper accountMapper;
	
	@Autowired
	protected  GoodsMapper goodsMapper;
	
	@Autowired
	protected  BuyOrderMapper buyOrderMapper;
	
	@Autowired
	protected  BuyOrderDetailMapper buyOrderDetailMapper;

	@Autowired
	protected  AccountRecordsMapper accountRecordsMapper;

	@Autowired
	protected  SysParamMapper sysParamMapper;

	@PostConstruct//在构造方法后，初化前执行
	private void initBaseMapper() throws Exception{

		//完成以下逻辑，需要对研发本身进行命名与使用规范
		//this关键字指对象本身，这里指的是调用此方法的实现类（子类）
		System.out.println("=======this :"+this);
		System.out.println("=======父类基本信息："+this.getClass().getSuperclass());
		System.out.println("=======父类和泛型的信息："+this.getClass().getGenericSuperclass());

		ParameterizedType type =(ParameterizedType) this.getClass().getGenericSuperclass();
		//获取第一个参数的class
		Class clazz = (Class)type.getActualTypeArguments()[0];
		System.out.println("=======class:"+clazz);
		//转化为属性名（相关的Mapper子类的引用名）Supplier  supplierMapper
		String localField = clazz.getSimpleName().substring(0,1).toLowerCase()+clazz.getSimpleName().substring(1)+"Mapper";
		System.out.println("=======localField:"+localField);

		//getDeclaredField:可以使用于包括私有、默认、受保护、公共字段，但不包括继承的字段
		Field field=this.getClass().getSuperclass().getDeclaredField(localField);
		System.out.println("=======field:"+field);
		System.out.println("=======field对应的对象:"+field.get(this));


		Field baseField = this.getClass().getSuperclass().getDeclaredField("baseMapper");
		System.out.println("=======baseField:"+baseField);
		System.out.println("=======baseField对应的对象:"+baseField.get(this));
		//field.get(this)获取当前this的field字段的值。例如：Supplier对象中，baseMapper所指向的对象为其子类型SupplierMapper对象，子类型对象已被spring实例化于容器中
		baseField.set(this, field.get(this));
		System.out.println("========baseField对应的对象:"+baseMapper);

	}	
	
}

```

这个baseService并没有给出对应的setDao的方法，那它是怎么将BaseDao实例化的呢？？？**关键就在于initBaseMapper()这个方法！**

我们来看一下方法内部打印数据的内容吧：

```
=======this :cn.itcast.scm.service.impl.BuyOrderServiceImpl@13a739e
=======父类基本信息：class cn.itcast.scm.service.impl.BaseServiceImpl
=======父类和泛型的信息：cn.itcast.scm.service.impl.BaseServiceImpl<cn.itcast.scm.entity.BuyOrder>
=======class:class cn.itcast.scm.entity.BuyOrder
=======localField:buyOrderMapper

=======field:protected cn.itcast.scm.dao.BuyOrderMapper cn.itcast.scm.service.impl.BaseServiceImpl.buyOrderMapper
=======field对应的对象:org.apache.ibatis.binding.MapperProxy@7cc946
=======baseField:protected cn.itcast.scm.dao.BaseMapper cn.itcast.scm.service.impl.BaseServiceImpl.baseMapper
=======baseField对应的对象:null
========baseField对应的对象:org.apache.ibatis.binding.MapperProxy@7cc946
```

这个方法被@PostConstruct注解给修饰着

- 于是**这个方法的执行是在Servlet构造函数之后、Servlet的init()方法之前被执行！**


通过我一阵的梳理，BaseDao的实例化过程是这样的：

- 我们具体的ServiceImpl被Spring所管理着，当具体serviceImpl被Spring实例化时，会自动调用其父类也就是baseServiceImpl
- 当发现父类baseServiceImpl有@PostConstruct注解给修饰，于是就调用initBaseMapper()
- 这个方法首先是获取泛型的信息（例如：BuyOrder）
- **将泛型的信息与Mapper字符串进行拼接，拼接成(BuyOrderMapper)**
- **通过反射获取baseServiceImpl的成员变量buyOrderMapper--->这个是Mapper代理的对象，从上面的输出对象就可以看出来。**
- **然后也通过反射将baseMapper进行实例化。**


其实上面也是通过具体的serviceImpl来对baseDao来进行初始化，不过它这样子做的话就显得更加优雅了。并不需要在每个具体的serviceImpl使用setDao()的方式来进行实例化。


通过上面的解释、我们把注释写上，就很容易理解了。

```java

	/**
	 * 每当service实例化的时候，这个方法都会被调用
	 * @throws Exception
     */
	@PostConstruct
	private void initBaseMapper() throws Exception{

		//获取泛型的信息
		ParameterizedType type =(ParameterizedType) this.getClass().getGenericSuperclass();
		Class clazz = (Class)type.getActualTypeArguments()[0];

		//拼接成“泛型”Mapper字符串
		String localField = clazz.getSimpleName().substring(0,1).toLowerCase()+clazz.getSimpleName().substring(1)+"Mapper";

		//通过反射来获取成员变量的值
		Field field=this.getClass().getSuperclass().getDeclaredField(localField);
		Field baseField = this.getClass().getSuperclass().getDeclaredField("baseMapper");

		//将baseDao来进行实例化
		baseField.set(this, field.get(this));
	}

```

# 分析项目的业务 #

本项目主要用EASY-UI来作为前段的页面构建。这里就不一一去探究EASY-UI的用法的，当用到这个前段UI的时候再回头看吧。下面就直接分析它的具体逻辑体悟了。


## 用户登陆 ##

首先，程序的入口是用户登录的界面。**用户设计得比较简单，因为只用来做登录。**

```sql


CREATE TABLE account
(
    acc_id INT(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
    acc_login VARCHAR(20),
    acc_name VARCHAR(20),
    acc_pass VARCHAR(20)
);

```

对于用户登陆而言，我们已经是非常熟悉这个业务了。**只是在数据库中对比一下数据、如果存在这个数据，那么在session域中保存即可！**

![](http://images2017.cnblogs.com/blog/1053130/201710/1053130-20171022085734756-1648391716.png)


## 基本数据的数据库表 ##
![](http://images2017.cnblogs.com/blog/1053130/201710/1053130-20171022091954599-1094493269.png)
```sql

CREATE TABLE supplier
(
    sup_id INT(11) PRIMARY KEY NOT NULL,
    sup_name VARCHAR(20),
    sup_linkman VARCHAR(20),
    sup_phone VARCHAR(11),
    sup_address VARCHAR(100),
    sup_remark VARCHAR(100),
    sup_pay DECIMAL(12,2),
    sup_type VARCHAR(10)
);
```

![](http://images2017.cnblogs.com/blog/1053130/201710/1053130-20171022085801521-242891098.png)

```sql


CREATE TABLE goods
(
    goods_Id VARCHAR(36) PRIMARY KEY NOT NULL,
    goods_name VARCHAR(20),
    goods_unit VARCHAR(10),
    goods_type VARCHAR(10),
    goods_color VARCHAR(10),
    goods_store INT(11),
    goods_limit INT(11),
    goods_commission DECIMAL(2,2),
    goods_producer VARCHAR(50),
    goods_remark VARCHAR(100),
    goods_sel_price DECIMAL(12,2),
    goods_buy_price DECIMAL(12,2)
);
```
![](http://images2017.cnblogs.com/blog/1053130/201710/1053130-20171022091809037-778712277.png)


```sql
CREATE TABLE store_house
(
    sh_id VARCHAR(10) PRIMARY KEY NOT NULL,
    sh_name VARCHAR(20),
    sh_responsible VARCHAR(20),
    sh_phone VARCHAR(11),
    sh_address VARCHAR(50),
    sh_type VARCHAR(10),
    sh_remark VARCHAR(100)
);

```

上边这几张表都仅仅是CRUD的操作。

- 上面已经说了，我们的URL都交由了baseAction来进行处理。但是我们需要增加、查询的时候可能是需要数据库中查询出来的数据的。当然了，有些是可以通过easy-UI部分的控件能从数据库中获取得到【分页数据】，可是有的地方还是需要我们手动去查询出来。


那么这个项目是这样处理的，**将经常用到的数据用一张表保存起来**。

```sql



drop table if exists sys_param;
/*====================================系统参数表==============================*/
/*==============================================================*/
/* Table: sys_param                                             */
/*==============================================================*/
/*
create table sys_param
(
   sys_param_id         bigint  auto_increment,
   sys_param_field      varchar(50),
   sys_param_value      varchar(50),
   sys_param_text       varchar(50),
   primary key (sys_param_id)
);
*/
create table sys_param
(
   sys_param_id         bigint  auto_increment,
   sys_param_field      varchar(50),
   sys_param_value      varchar(500),
   sys_param_text       varchar(50),
   sys_param_type       varchar(2),   
   primary key (sys_param_id)
);
insert into sys_param(sys_param_field,sys_param_value,sys_param_type) values('shId','select s.sh_id as sys_param_value,s.sh_name as sys_param_text from store_house s','1');


insert into sys_param(sys_param_field,sys_param_value,sys_param_text) values('supType','1','一级供应商');
insert into sys_param(sys_param_field,sys_param_value,sys_param_text) values('supType','2','二级供应商');
insert into sys_param(sys_param_field,sys_param_value,sys_param_text) values('supType','3','普通供应商');
insert into sys_param(sys_param_field,sys_param_value,sys_param_text) values('goodsColor','1','红色');
insert into sys_param(sys_param_field,sys_param_value,sys_param_text) values('goodsColor','2','绿色');
insert into sys_param(sys_param_field,sys_param_value,sys_param_text) values('goodsColor','3','蓝色');
select * from sys_param;

```

上面我们可以看到，除了单单保存了一些的基本属性之外，我们来存储了SQL语句，那么我们怎么将SQL语句转成是我们的数据呢？？？

- 上面就是查询仓库的地址。**也就是说，当页面加载的时候，我们的地址就被查询出来了。**

![](http://images2017.cnblogs.com/blog/1053130/201710/1053130-20171022093918162-512069077.png)


那它是怎么实现这种玩意的呢？？


Mapper查询表的数据
```xml

  <select id="selectList" parameterType="String" resultMap="sysParamResultMap">  	
  	select * from sys_param
  </select>
  
  <!-- 查询其它表的数据,使用${value}格式，允许使用sql语句作为参数执行 -->
  <select id="selectOthreTable" parameterType="string" resultMap="sysParamResultMap">
  	${value}
  </select>
```

Service将数据封装到一个总的Map中。具体的做法是这样子的：

```java

package cn.itcast.scm.service.impl;

import cn.itcast.scm.entity.SysParam;
import cn.itcast.scm.service.SysParamService;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service("sysParamService")
public class SysParamServiceImpl extends BaseServiceImpl<SysParam> implements SysParamService {

    @Override
    public Map<String, Object> selectList() {

        //查询出表中所有所有数据
        List<SysParam> sysParams = sysParamMapper.selectList("");

        //存储属性字段具体的值
        Map<String, Object> fieldMap = null;

        //最终的Map，key是属性字段，value是一个map(属性字段具体的值）
        Map<String, Object> sysParamMap = new HashMap<String, Object>();


        //遍历表中的记录，看是否有类型为1的字段数据！也就是SQL数据
        for (SysParam sysParam : sysParams) {
            if ("1".equals(sysParam.getSysParamType())) {
                String sql = sysParam.getSysParamValue();
                //执行SQL，得到查询后的记录
                List<SysParam> otherList = sysParamMapper.selectOthreTable(sql);
                fieldMap = new HashMap<>();

                /**
                 * select s.sh_id as sys_param_value,s.sh_name as sys_param_text  from store_house s
                 */
                //遍历查询后的记录，并把数据存到字段MAP
                for (SysParam otherSysParam : otherList) {
                    /**
                     * key = 仓库的具体Id
                     * value = 页面显示的仓库名称
                     */
                    fieldMap.put(otherSysParam.getSysParamValue(), otherSysParam.getSysParamText());
                }
                /**
                 * key = shId
                 * value = 存储具体数据的Map集合
                 */
                sysParamMap.put(sysParam.getSysParamField(), fieldMap);

            } else {
                //判断系统参数的map中是否存在字段的map，如果不存在，就新建一个
                if (sysParamMap.get(sysParam.getSysParamField()) == null) {
                    fieldMap = new HashMap<>();
                    /**
                     * key  = 1
                     * value = 一级供应商
                     */
                    fieldMap.put(sysParam.getSysParamValue(), sysParam.getSysParamText());

                    /**
                     * key = supType
                     * value = 存储具体数据的Map集合
                     */
                    sysParamMap.put(sysParam.getSysParamField(), fieldMap);
                } else {

                    //如果存在，那么就在原先的Map集合中添加
                    fieldMap = (Map<String, Object>) sysParamMap.get(sysParam.getSysParamField());
                    fieldMap.put(sysParam.getSysParamValue(), sysParam.getSysParamText());
                }
            }
        }
        /**
         * key = shId        value = Map-->(1  主仓库）
         *                             （2  分仓库）
         *
         * key = supType    value= Map-->( 1   一级供应商)
         *                              ( 2  二级供应商)...
         * key = goodsColor  value = Map--> (1  红色）....
         */
        return sysParamMap;
    }
}
```

controller使用@PostConstruct注解，在初始化的时候就把数据加载到application域对象中

```java

	//系统启动时加载参数
	@PostConstruct
	public void initSysParam(){
		loadSysParam();
	}
	
	//用来加载系统参数	
	public void loadSysParam(){
		Map<String, Object> sysParamMap = sysParamService.selectList();
		application.setAttribute("sysParam", sysParamMap);
		System.out.println("===================系统参数加载成功2=====================");
	}
	


```

## 采购商品 ##

![](http://images2017.cnblogs.com/blog/1053130/201710/1053130-20171023123853988-2113620059.png)

采购表buy_order：

```
单号bo_id，供货商sup_id，仓库sh_id，收货日期bo_date，应付（实付+欠款+优惠）bo_payable，实付bo_paid，欠款bo_Arrears，原始单号bo_original_id，备注bo_remark，经办人bo_attn，操作员operator。

```

采购明细表buy_order_detail：
```

编号bod_id：商品名称goods_id，单位goods_unit，数量 bod_amount，进价bod_buy_price，总金额（可无）bod_total_price，    采购单号bo_id，手机串号列表（##分隔）bod_IMEI

```

账务表account_records:

```

编号ad_id,供货商编号sup_id，日期ad_date，单号(不同类型单号不一样）ad_order_id，类型(业务类型）ad_bus_type，应付ad_payable，
    实付ad_paid，欠款ad_arrears，优惠金额ad_discount，经办人ad_attn，操作员ad_operator。备注ad_remark

```

![](http://images2017.cnblogs.com/blog/1053130/201710/1053130-20171023122952863-1101220026.png)

数据在插入的时候涉及到了这三张的数据库表：

![](http://images2017.cnblogs.com/blog/1053130/201710/1053130-20171023123628332-495081928.png)

至于我们的财务表的数据是用于拓展的，属性的信息基本是在采购表中获取：

```java

	public int insertBuyOrder(BuyOrder buyOrder) throws Exception {
		// TODO Auto-generated method stub
		System.out.println("service.buyOrder:"+buyOrder);
		int i = 0;		
		//生成采购单号,bo表示采购业务
		
		//bo --商品采购
		//ro --商品退货
		//
		String boId ="bo"+UUID.randomUUID().toString().replace("-", "");
		System.out.println("boIduuid:"+boId);
		//设置采购单号
		buyOrder.setBoId(boId);		
		i = buyOrderMapper.insert(buyOrder);
		
		//设置采购明细主键及与采购单的外键值
		for(BuyOrderDetail bod : buyOrder.getBuyOrderDetails()){
			bod.setBodId(UUID.randomUUID().toString().replace("-", ""));
			bod.setBoId(boId);
		}
		buyOrderDetailMapper.insertList(buyOrder.getBuyOrderDetails());
		
		AccountRecords accountRecords = new AccountRecords();
		// 生成并设置怅务记录的主键
		accountRecords.setArId(String.valueOf("ar"+UUID.randomUUID().toString().replace("-", "")));
		accountRecords.setArAttn(buyOrder.getBoAttn());
		accountRecords.setArArrears(buyOrder.getBoArrears());
		//bo表示商品采购，可以在参数表中加入相关内容
		accountRecords.setArBusType("bo");
		accountRecords.setArDate(buyOrder.getBoDate());
		//优惠金额：用应付金额减去实付金额再减去欠款
		accountRecords.setArDiscount(buyOrder.getBoPayable().subtract(buyOrder.getBoPaid()).subtract(buyOrder.getBoArrears()));
		accountRecords.setArOperator(buyOrder.getBoOperator());
		//采购单号
		accountRecords.setArOrderId(buyOrder.getBoId());
		accountRecords.setArPaid(buyOrder.getBoPaid());
		accountRecords.setArPayable(buyOrder.getBoPayable());
		accountRecords.setArRemark(buyOrder.getBoRemark());
		accountRecords.setSupId(buyOrder.getSupId());
		accountRecordsMapper.insert(accountRecords);
		
		return i;
	}

```


# 总结 #

- Controller可以使用一个方法来**统一进行页面跳转**
- **分页对象的设计可以加上条件，类型为泛型**
- 抽取Service层时，可以使用`@PostConstruct//在构造方法后，初化前执行`来进行初始化Dao对象。


> 如果文章有错的地方欢迎指正，大家互相交流。习惯在微信看技术文章，想要获取更多的Java资源的同学，可以**关注微信公众号:Java3y**
