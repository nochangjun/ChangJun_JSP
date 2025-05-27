<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="project.*" %>
<jsp:useBean id="mgr" class="project.BoardMgr"/>
<jsp:useBean id="bean" class="project.BoardBean"/>
<%
    request.setCharacterEncoding("UTF-8");

    // 게시글 ID와 내용 가져오기
    int boardId = Integer.parseInt(request.getParameter("id"));
    String content = request.getParameter("content");
    
    // 세션에서 로그인한 사용자 ID 가져오기
    String memberId = (String)session.getAttribute("idKey");
    
    // 로그인 체크
    if(memberId == null || memberId.trim().equals("")) {
        response.sendRedirect("../login/login.jsp");
        return;
    }
    
    // 게시글 정보 가져오기
    BoardBean board = mgr.getBoard(boardId);
    
    // 자신이 작성한 글만 수정 가능
    if(board == null || !board.getMember_id().equals(memberId)) {
        response.sendRedirect("support_Board.jsp");
        return;
    }
    
    // 수정할 내용 설정
    bean.setBoard_id(boardId);
    bean.setBoard_title(board.getBoard_title()); // 제목은 그대로 유지
    bean.setBoard_content(content);
    
    // DB 업데이트
    boolean result = mgr.updateBoard(bean);
    
    // 결과에 따라 처리
    if(result) {
        // 성공 시 게시글 상세페이지로 리다이렉트
        response.sendRedirect("support_Board_Detail.jsp?id=" + boardId);
    } else {
        // 실패 시 에러 메시지 출력 후 이전 페이지로 이동
        out.println("<script>");
        out.println("alert('게시글 수정에 실패했습니다.');");
        out.println("history.back();");
        out.println("</script>");
    }
%>