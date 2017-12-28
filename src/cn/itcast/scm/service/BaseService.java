package cn.itcast.scm.service;

public interface BaseService<T> {
	//添加单个对象
	public int insert (T entity) throws Exception;
	
	//修改单个对象
	public int update(T entity) throws Exception;
	
	//删除单个对象
	public int delete(T entity) throws Exception;
	
	//查询单个对象
	public T select(T entity);
}
