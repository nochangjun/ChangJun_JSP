<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="project.*" %>
<jsp:useBean id="mgr" class="project.BoardMgr"/>
<jsp:useBean id="bean" class="project.BoardBean"/>
<% 

    // 세션에서 로그인한 사용자 ID 가져오기
    String memberId = (String)session.getAttribute("idKey");
    
    // 로그인 체크
    if(memberId == null || memberId.trim().equals("")) {
        response.sendRedirect("../login/login.jsp");
        return;
    }
    
 // 게시글 작성 금지 여부 체크
    MemberMgr memberMgr = new MemberMgr();
    boolean canPost = memberMgr.canPost(memberId); // 게시글 작성 가능 여부 확인
    
    // 폼 제출 시 처리
    if(request.getMethod().equals("POST")) {
        request.setCharacterEncoding("UTF-8");
        
        // Bean에 값 설정
        bean.setMember_id(memberId);
        bean.setBoard_title(request.getParameter("title"));
        bean.setBoard_content(request.getParameter("content"));
        
        // DB에 저장
        mgr.insertBoard(bean);
        
        // 게시판 목록 페이지로 리다이렉트
        response.sendRedirect("support_Board.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>게시글 작성하기</title>
<link rel="stylesheet" type="text/css" href="../css/support_Board_Write.css">
<jsp:include page="../header.jsp"></jsp:include>
</head>
<body>
<div class="board-container">
    <div class="board-title">게시글 작성하기</div>
    <div class="divider-line"></div>
    
    <% if (!canPost) { %>
        <div class="alert-message">
            현재 게시글 작성이 금지되어 있습니다. 금지 기간이 종료될 때까지 게시글을 작성할 수 없습니다.
        </div>
    <% } else { %>

    <form action="support_Board_Write.jsp" method="post" class="Board_Write" id="Board_Write">
        <div class="form-group">
            <label class="form-label">제목</label>
            <div class="relative">
                <input type="text" class="form-control" placeholder="25자 이내로 작성해주세요" name="title" maxlength="25" required>
            </div>
        </div>

        <div class="form-group">
            <label class="form-label">내용</label>
            <textarea class="form-control" placeholder="내용을 입력해주세요" name="content" required></textarea>
        </div>

        <!-- 등록 버튼 - 오른쪽 아래에 배치 -->
        <div class="submit-button-container">
            <button type="button" class="submit-button" id="submitBtn">등록</button>
        </div>
        
        <!-- 목록 버튼 - 중앙에 배치 -->
        <div class="list-button-container">
            <button type="button" onclick="location.href='support_Board.jsp'" class="list-button">목록</button>
        </div>
    </form>
    <% } %>
</div>

<jsp:include page="../footer.jsp"></jsp:include>

<script>
// 등록 버튼 클릭 시 확인 대화상자 표시
document.getElementById('submitBtn').addEventListener('click', function() {
            const title = document.querySelector('input[name="title"]').value.trim();
            const content = document.querySelector('textarea[name="content"]').value.trim();

            // 유효성 검사
            if (!title) {
                alert('제목을 입력해주세요.');
                return;
            }

            if (!content) {
                alert('내용을 입력해주세요.');
                return;
            }

            // 확인 대화상자 표시
            if (confirm('게시글을 등록하시겠습니까?')) {
                // '네' 클릭 시 폼 제출
                document.getElementById('Board_Write').submit();
            } else {
                // '아니오' 클릭 시 아무 작업도 수행하지 않음 (현재 페이지에 머무름)
                return false;
            }
        });
</script>
</body>
</html>