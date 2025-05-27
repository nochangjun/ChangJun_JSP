<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="project.*" %>
<jsp:useBean id="mgr" class="project.InquiryMgr"/>
<jsp:useBean id="bean" class="project.InquiryBean"/>
<%
	// 세션에서 로그인한 사용자 ID 가져오기 (세션 변수명은 프로젝트에 맞게 수정 필요)
	String memberId = (String)session.getAttribute("idKey");
	
	// 로그인 체크
	if(memberId == null || memberId.trim().equals("")) {
		response.sendRedirect("../login/login.jsp");
		return;
	}
	
	// 폼 제출 시 처리
	if(request.getMethod().equals("POST")) {
		request.setCharacterEncoding("UTF-8");
		
		// Bean에 값 설정
		bean.setMember_id(memberId);
		bean.setInq_type(request.getParameter("category"));
		bean.setInq_title(request.getParameter("title"));
		bean.setInq_content(request.getParameter("content"));
		
		// DB에 저장
		mgr.insertInquiry(bean);
		
		// 문의 목록 페이지로 리다이렉트
		response.sendRedirect("support_Inquiry.jsp");
	}
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>1:1 문의하기</title>
    <link rel="stylesheet" type="text/css" href="../css/support_Inquiry_Write.css">
    <jsp:include page="../header.jsp"></jsp:include>
</head>
<body>
<div class="inquiry-container">
    <div class="inquiry-title">1:1 문의하기</div>
    <div class="inquiry-subtitle">궁금한 점을 문의해주세요.</div>
    <div class="divider-line"></div>

    <form action="support_Inquiry_Write.jsp" method="post" class="Inquiry_Write" id="Inquiry_Write">
        <!-- New Category Selection Section -->
        <div class="form-group">
            <label class="form-label">문의 카테고리</label>
            <div class="category-buttons">
                <input type="radio" id="account-inquiry" name="category" value="계정문의" required>
                <label for="account-inquiry" class="category-button">계정 문의</label>

                <input type="radio" id="store-inquiry" name="category" value="가게문의">
                <label for="store-inquiry" class="category-button">가게 문의</label>

                <input type="radio" id="etc-inquiry" name="category" value="기타">
                <label for="etc-inquiry" class="category-button">기타</label>
            </div>
        </div>

        <div class="form-group">
            <label class="form-label">질문입력</label>
            <div class="relative">
                <input type="text" class="form-control with-icon" placeholder="30자 이내로 작성해주세요" name="title" maxlength="30" required>
                <span class="q-icon">Q</span>
            </div>
        </div>

        <div class="form-group">
            <label class="form-label">내용</label>
            <textarea class="form-control" placeholder="내용을 입력해주세요" name="content" required></textarea>
        </div>

        <!-- 버튼 컨테이너 추가 -->
        <div class="button-container">
            <button type="button" class="inquiry-button" id="submitBtn">등록</button>
            <a href="support_Inquiry.jsp" class="list-button">목록</a>
        </div>
    </form>
</div>

<jsp:include page="../footer.jsp"></jsp:include>

<script>
// 문의하기 버튼 클릭 시 확인 대화상자 표시
document.getElementById('submitBtn').addEventListener('click', function() {
    const category = document.querySelector('input[name="category"]:checked');
    const title = document.querySelector('input[name="title"]').value.trim();
    const content = document.querySelector('textarea[name="content"]').value.trim();

    // 유효성 검사
    if (!category) {
        alert('문의 카테고리를 선택해주세요.');
        return;
    }

    if (!title) {
        alert('제목을 입력해주세요.');
        return;
    }

    if (!content) {
        alert('내용을 입력해주세요.');
        return;
    }

    // 확인 대화상자 표시
    if (confirm('문의하시겠습니까?')) {
        // '네' 클릭 시 폼 제출
        document.getElementById('Inquiry_Write').submit();
    } else {
        // '아니오' 클릭 시 아무 작업도 수행하지 않음 (현재 페이지에 머무름)
        return false;
    }
});
</script>
</body>
</html>