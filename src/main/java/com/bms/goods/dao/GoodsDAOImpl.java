package com.bms.goods.dao;

import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Repository;

import com.bms.goods.dto.GoodsDTO;
import com.bms.goods.dto.ImageFileDTO;

@Repository("goodsDAO")
public class GoodsDAOImpl  implements GoodsDAO{
	
	@Autowired
	private SqlSession sqlSession;

	@Override
	public List<GoodsDTO> selectGoodsList(String goodsStatus ) throws DataAccessException {
	   return sqlSession.selectList("mapper.goods.selectGoodsList",goodsStatus);	
	}
	
	@Override
	public List<String> selectKeywordSearch(String keyword) throws DataAccessException {
	   return sqlSession.selectList("mapper.goods.selectKeywordSearch",keyword);
	}
	
	@Override
	public List<GoodsDTO> selectGoodsBySearchWord(String searchWord) throws DataAccessException{
		 return sqlSession.selectList("mapper.goods.selectGoodsBySearchWord",searchWord);
	}
	
	@Override
	public GoodsDTO selectGoodsDetail(String goodsId) throws DataAccessException{
		return sqlSession.selectOne("mapper.goods.selectGoodsDetail",goodsId);
	}
	
	@Override
	public List<ImageFileDTO> selectGoodsDetailImage(String goodsId) throws DataAccessException{
		return sqlSession.selectList("mapper.goods.selectGoodsDetailImage",goodsId);
	}
	
}
