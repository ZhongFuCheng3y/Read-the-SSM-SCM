package cn.itcast.scm.service;

import cn.itcast.scm.entity.Account;

public interface AccountService extends BaseService<Account> {
	 public Account login(Account account);
}
