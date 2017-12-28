package cn.itcast.scm.dao;

public interface BaseMapper<T> {
	//添加单个对象
	public int insert(T entity);
	
	//修改单个对象
	public int update(T entity);
	
	//删除单个对象
	public int delete(T entity);
	
	//查询单个对象
	public T select(T entity);
}
