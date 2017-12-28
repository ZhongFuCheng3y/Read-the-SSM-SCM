package cn.itcast.scm.entity;

import java.io.Serializable;

public class Supplier implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = -3051147093149131879L;

	private Integer supId;

	private String supName;

	private String supLinkman;

	private String supPhone;

	private String supAddress;

	private String supRemark;

	public Integer getSupId() {
		return supId;
	}

	public void setSupId(Integer supId) {
		this.supId = supId;
	}

	public String getSupName() {
		return supName;
	}

	public void setSupName(String supName) {
		this.supName = supName;
	}

	public String getSupLinkman() {
		return supLinkman;
	}

	public void setSupLinkman(String supLinkman) {
		this.supLinkman = supLinkman;
	}

	public String getSupPhone() {
		return supPhone;
	}

	public void setSupPhone(String supPhone) {
		this.supPhone = supPhone;
	}

	public String getSupAddress() {
		return supAddress;
	}

	public void setSupAddress(String supAddress) {
		this.supAddress = supAddress;
	}

	public String getSupRemark() {
		return supRemark;
	}

	public void setSupRemark(String supRemark) {
		this.supRemark = supRemark;
	}

	@Override
	public String toString() {
		return "Supplier [supId=" + supId + ", supName=" + supName
				+ ", supLinkman=" + supLinkman + ", supPhone=" + supPhone
				+ ", supAddress=" + supAddress + ", supRemark=" + supRemark
				+ "]";
	}

}