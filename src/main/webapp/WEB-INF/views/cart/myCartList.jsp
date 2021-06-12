<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="contextPath" value="${pageContext.request.contextPath}"  />
<c:set var="myCartList"  value="${cartMap.myCartList}"  />
<c:set var="myGoodsList" value="${cartMap.myGoodsList}"  />

<c:set var="totalGoodsNum" value="0" />  			<!--주문 개수 -->
<c:set var="totalDeliveryPrice" value="0" /> 		<!-- 총 배송비 --> 
<c:set var="totalDiscountedPrice" value="0" /> 		<!-- 총 할인금액 -->


<head>
<script src="${contextPath}/resources/jquery/jquery-3.5.1.min.js"></script>
<script>

	function calcGoodsPrice(bookPrice, obj, cartGoodsQty, goodsSalesPrice){
		
		var totalPrice, totalDiscountedPrice, final_total_price, totalNum;
		
		var p_totalNum          	 = $("#p_totalGoodsNum");
		var p_totalPrice        	 = $("#p_totalGoodsPrice");
		var p_totalDiscountedPrice   = $("#p_totalDiscountedPrice");
		var p_final_totalPrice  	 = $("#p_final_totalPrice");
		var h_totalNum          	 = $("#h_totalGoodsNum");
		var h_totalPrice        	 = $("#h_totalGoodsPrice");
		var h_totalDelivery     	 = $("#h_totalDeliveryPrice");
		var h_totalDiscountedPrice   = $("#h_totalDiscountedPrice");
		var h_final_total_price 	 = $("#h_final_totalPrice");
		
		if (obj.checked){
			
			totalNum				= Number(h_totalNum.val()) + Number(cartGoodsQty);
			totalPrice				= Number(h_totalPrice.val()) + cartGoodsQty * bookPrice;
			totalDiscountedPrice	= Number(h_totalDiscountedPrice.val()) + cartGoodsQty * (bookPrice - goodsSalesPrice);
			final_total_price		= Number(totalPrice) + Number(h_totalDelivery.val()) - Number(totalDiscountedPrice);
				
		}
		else {
			totalNum				= Number(h_totalNum.val()) - Number(cartGoodsQty);
			totalPrice				= Number(h_totalPrice.val()) - cartGoodsQty * bookPrice;
			totalDiscountedPrice	= Number(h_totalDiscountedPrice.val()) - cartGoodsQty * (bookPrice - goodsSalesPrice);
			final_total_price		= Number(totalPrice) + Number(h_totalDelivery.val()) - Number(totalDiscountedPrice);
		}
		
		h_totalNum.val(totalNum);
		h_totalPrice.val(totalPrice);
		h_totalDiscountedPrice.val(totalDiscountedPrice);
		h_final_total_price.val(final_total_price);
		
		const tp = totalPrice;
		const tdp = totalDiscountedPrice;
		const ftp = final_total_price;

		const ctp = tp.toString().replace(/\B(?<!\.\d*)(?=(\d{3})+(?!\d))/g, ",");
		const ctdp = tdp.toString().replace(/\B(?<!\.\d*)(?=(\d{3})+(?!\d))/g, ",");
		const cftp = ftp.toString().replace(/\B(?<!\.\d*)(?=(\d{3})+(?!\d))/g, ",");
		
		p_totalNum.text(totalNum + "개");
		p_totalPrice.text(ctp + "원");
		p_totalDiscountedPrice.text(ctdp + "원");
		p_final_totalPrice.text(cftp + "원");
		
	}
	
	function modify_cart_qty(goodsId, cartId){
		
		var length = document.frm_order_all_cart.cartGoodsQty.length;
	  	var cartGoodsQty = 0;
	  	var cartIdx = cartId - 1;
	  	
	  	if (length>1) { //카트에 제품이 한개인 경우와 여러개인 경우 나누어서 처리한다.
	  		cartGoodsQty = document.frm_order_all_cart.cartGoodsQty[cartIdx].value;
		} else {
			cartGoodsQty = document.frm_order_all_cart.cartGoodsQty.value;
		}
	  	
		$.ajax({
			type : "post",
			url : "${contextPath}/cart/modifyCartQty.do",
			data : {
				goodsId       : goodsId,
				cartGoodsQty  : cartGoodsQty
			},
			
			success : function(data, textStatus) {
				alert("수량을 변경했습니다.");
				
			},
			error : function(data, textStatus) {
				alert("에러가 발생했습니다."+data);
			},
			
		});	
	}
	
	function delete_cart_goods(cartId){
	   location.href = "${contextPath}/cart/removeCartGoods.do?cartId=" + Number(cartId);
	}
	
	
	function fn_order_each_goods(goodsId , goodsTitle , goodsSalesPrice , fileName, goodsQty) {
		
		var total_price, final_total_price, _goods_qty;
		
		_order_goods_qty	    = goodsQty; //장바구니에 담긴 개수 만큼 주문한다.
		var formObj             = document.createElement("form");
		var i_goods_id          = document.createElement("input"); 
	    var i_goods_title       = document.createElement("input");
	    var i_goods_sales_price = document.createElement("input");
	    var i_fileName          = document.createElement("input");
	    var i_order_goods_qty   = document.createElement("input");
	    
	    i_goods_id.name          = "goodsId";
	    i_goods_title.name       = "goodsTitle";
	    i_goods_sales_price.name = "goodsSalesPrice";
	    i_fileName.name          = "goodsFileName";
	    i_order_goods_qty.name   = "orderGoodsQty";
	    
	    i_goods_id.value          = goodsId;
	    i_order_goods_qty.value   = _order_goods_qty;
	    i_goods_title.value       = goodsTitle;
	    i_goods_sales_price.value = goodsSalesPrice;
	    i_fileName.value          = fileName;
	    
	    formObj.appendChild(i_goods_id);
	    formObj.appendChild(i_goods_title);
	    formObj.appendChild(i_goods_sales_price);
	    formObj.appendChild(i_fileName);
	    formObj.appendChild(i_order_goods_qty);
	
	    document.body.appendChild(formObj);
	    
	    formObj.method="post";
	    formObj.action="${contextPath}/order/orderEachGoods.do";
	    formObj.submit();
	}
	
	
	function fn_order_all_cart_goods(){
		
		var order_goods_qty;											//for문의 해당 상품(선택)의 개수
		var order_goods_id;												//for문의 해당 상품(선택)의 id
		var objForm					= document.frm_order_all_cart;		//장바구니 form 전체
		var totalPriceForm			= document.frm_total_cart_price;	//합산 form 전체
		
		var cart_goods_qty			= objForm.cartGoodsQty;				//각 상품의 개수(선택/해제 구분X)
		var checked_goods			= objForm.checked_goods;			//checkBox가 선택된 상품
		var length					= checked_goods.length;				//선택된 상품 개수
		
		//장바구니의 상품이 2개 이상
		if (length>1){
			
			for (var i=0; i<length;i++){
				//checkBox의 선택/해제 확인
				if (checked_goods[i].checked == true){
					
					order_goods_id = checked_goods[i].value;
					order_goods_qty = cart_goods_qty[i].value;
					cart_goods_qty[i].value = "";
					cart_goods_qty[i].value = order_goods_id + ":" + order_goods_qty;
					
					console.log(cart_goods_qty[i].value);
					
				}
			}
			
		}
		else {
			order_goods_id = checked_goods.value;
			order_goods_qty = cart_goods_qty.value;
			cart_goods_qty.value = order_goods_id + ":" + order_goods_qty;
		}
		
	 	objForm.method="post";
	 	objForm.action="${contextPath}/order/orderAllCartGoods.do";
		objForm.submit();
				
	}

</script>
</head>
<body>

	<table class="list_view">
		<thead>
			<tr style="background:; height: 40px;">
				<th id="content" class="fixed">구분</th>
				<th colspan=2 class="fixed">상품명</th>
				<th>정가</th>
				<th>판매가</th>
				<th>수량</th>
				<th>합계</th>
				<th>주문</th>
			</tr>
		</thead>
		<tbody align=center >
			<c:choose>
			    <c:when test="${ empty myCartList }">
			    <tr>
			       <td colspan=8 class="fixed">
			         <strong>장바구니에 상품이 없습니다.</strong>
			       </td>
			     </tr>
			    </c:when>
		        <c:otherwise>
               		<form name="frm_order_all_cart">
						<c:forEach var="item" items="${myGoodsList }" varStatus="cnt">
						<c:set var="cartGoodsQty" value="${myCartList[cnt.index].cartGoodsQty}" />
						<tr>
					      	<c:set var="cartId" value="${myCartList[cnt.index].cartId}" />
							<td><input type="checkbox" id="checked_goods" name="checked_goods" checked value="${item.goodsId }" onclick="calcGoodsPrice(${item.goodsPrice},this, ${cartGoodsQty}, ${item.goodsSalesPrice})"></td>
							<td class="goods_image">
							<a href="${contextPath}/goods/goodsDetail.do?goodsId=${item.goodsId }">
								<img width="75" alt="" src="${contextPath}/thumbnails.do?goodsId=${item.goodsId}&fileName=${item.goodsFileName}"  />
							</a>
							</td>
							<td>
								<h2>
									<a href="${contextPath}/goods/goodsDetail.do?goodsId=${item.goodsId }">${item.goodsTitle }</a>
								</h2>
							</td>
							<td class="price"><span><fmt:formatNumber value="${item.goodsPrice}" type="number" />원</span></td>
							<td>
							   <strong>
							      <fmt:formatNumber value="${item.goodsSalesPrice}" type="number" />원(
							      <fmt:formatNumber value="${((item.goodsPrice-item.goodsSalesPrice) / (item.goodsPrice))}" type="percent" pattern="0%" />
						           ${discountRate}할인)
						         </strong>
							</td>
							<td>
								<input type="text" id="cartGoodsQty" name="cartGoodsQty" size="1" value="${cartGoodsQty}"><br>
								<a href="javascript:modify_cart_qty(${item.goodsId }, ${myCartList[cnt.count-1].cartId});" >
								    <img width=30 alt="변경"  src="${contextPath}/resources/image/btn_modify_qty.jpg">
								</a>
							</td>
							<td>
							   <strong>
							    <fmt:formatNumber value="${item.goodsSalesPrice * cartGoodsQty}" type="number" var="totalSalesPrice" />
						         ${totalSalesPrice}원
								</strong> 
							</td>
							<td>
							    <a href="javascript:fn_order_each_goods('${item.goodsId }','${item.goodsTitle }','${item.goodsSalesPrice}','${item.goodsFileName}', '${cartGoodsQty }');">
							       	<img width="75" alt="" src="${contextPath}/resources/image/btn_order.jpg">
									</a><br> 
								<a href="#"> 
								   <img width="75" alt="" src="${contextPath}/resources/image/btn_add_list.jpg">
								</a><br> 
								<a href="javascript:delete_cart_goods('${cartId}');"> 
								   <img width="75" alt="" src="${contextPath}/resources/image/btn_delete.jpg">
							   </a>
							</td>
						</tr>
						<c:set var="totalGoodsPrice" value="${totalGoodsPrice + (item.goodsPrice * cartGoodsQty) }" />
						<c:set var="totalGoodsNum" value="${totalGoodsNum + cartGoodsQty}" />
						<c:set var="totalDiscountedPrice" value="${totalDiscountedPrice + ((item.goodsPrice - item.goodsSalesPrice) * cartGoodsQty)}" />
						<c:set var="goodsPrice" value="${item.goodsPrice}" />
						<c:set var="goodsSalesPrice" value="${item.goodsSalesPrice}" />
						<c:choose>
							<c:when test="${item.goodsDeliveryPrice == 0}">
								<c:set var="totalDeliveryPrice" value="0" />
							</c:when>
							<c:when test="${totalGoodsPrice gt 50000}">
								<c:set var="totalDeliveryPrice" value="0" />
							</c:when>
							<c:otherwise>
								<c:set var="totalDeliveryPrice" value="2500" />
							</c:otherwise>
						</c:choose>
						</c:forEach>
						<input id="final_totalPrice" name="final_totalPrice" type="hidden" value="${totalGoodsPrice+totalDeliveryPrice-totalDiscountedPrice}" />
					<div class="clear"></div>
					</form>
				</c:otherwise>
			</c:choose> 
	</tbody>
	</table>
     	
	<br>
	<br>
	
	<form name="frm_total_cart_price">
		<table class="list_view" style="background:; width:100%">
			<tbody>
			     <tr align=center  class="fixed" >
			       <td class="fixed">총 상품수 </td>
			       <td>총 상품금액</td>
			       <td></td>
			       <td>총 배송비</td>
			       <td></td>
			       <td>총 할인 금액 </td>
			       <td></td>
			       <td>최종 결제금액</td>
			     </tr>
				<tr align="center" >
					<td id="">
					  <p id="p_totalGoodsNum">${totalGoodsNum}개</p>
					  <input id="h_totalGoodsNum" name="h_totalGoodsNum" type="hidden" value="${totalGoodsNum}"  />
					</td>
			       <td>
			          <p id="p_totalGoodsPrice">
			           <fmt:formatNumber value="${totalGoodsPrice}" type="number" />원
			          </p>
			          <input id="h_totalGoodsPrice" name="h_totalGoodsPrice" type="hidden" value="${totalGoodsPrice}" />
			       </td>
			       <td> 
			          <img width="25" alt="" src="${contextPath}/resources/image/plus.jpg">  
			       </td>
			       <td>
			         <p id="p_totalDeliveryPrice">
			         	<fmt:formatNumber value="${totalDeliveryPrice }" type="number" />원  </p>
			         <input id="h_totalDeliveryPrice" name="h_totalDeliveryPrice" type="hidden" value="${totalDeliveryPrice}" />
			       </td>
			       <td> 
			         <img width="25" alt="" src="${contextPath}/resources/image/minus.jpg"> 
			       </td>
			       <td>  
			         <p id="p_totalDiscountedPrice" style=""><fmt:formatNumber value="${totalDiscountedPrice}" type="number" />원</p>
			         <input id="h_totalDiscountedPrice" name="h_totalDiscountedPrice" type="hidden" value="${totalDiscountedPrice}" />
			       </td>
			       <td>  
			         <img width="25" alt="" src="${contextPath}/resources/image/equal.jpg">
			       </td>
			       <td>
			          <p id="p_final_totalPrice">
			           <fmt:formatNumber value="${totalGoodsPrice+totalDeliveryPrice-totalDiscountedPrice}" type="number" />원
			           </p>
			          <input id="h_final_totalPrice" name="h_final_totalPrice" type="hidden" value="${totalGoodsPrice+totalDeliveryPrice-totalDiscountedPrice}" />
			       </td>
				</tr>
			</tbody>
		</table>
	</form>
	
	<div align="right">
    <br><br>	
	 <a href="javascript:fn_order_all_cart_goods()">
	 	<img width="90" alt="" src="${contextPath}/resources/image/btn_order_final.jpg">
	 </a>
	 <a href="${contextPath}/main/main.do">
	 	<img width="75" alt="" src="${contextPath}/resources/image/btn_shoping_continue.jpg">
	 </a>
	</div>
	
</body>
</html>