<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, javax.servlet.http.Cookie, java.net.URLEncoder, project.*" %>
<%@ page import="java.net.URLEncoder" %>

<%
    String memberId = (String) session.getAttribute("idKey");

	response.setContentType("application/json; charset=UTF-8");
	
	if (memberId == null) {
	    out.print("{\"error\": \"로그인이 필요합니다.\"}");
	    return;
	}
	
	String encodedMemberId = URLEncoder.encode(memberId, "UTF-8");
    int boardId = Integer.parseInt(request.getParameter("boardId"));
    boolean liked = false;
    int likeCount = 0;

    if (memberId != null) {
    	
        HashSet<String> likedPosts = (HashSet<String>) application.getAttribute("likedPosts");
        if (likedPosts == null) {
            likedPosts = new HashSet<>();
            application.setAttribute("likedPosts", likedPosts);
        }

        String likeKey = encodedMemberId + "_post_" + boardId;
        BoardMgr mgr = new BoardMgr();
        Integer currentLikes = mgr.getBoard(boardId).getBoard_like();
        if (currentLikes == null) currentLikes = 0;

        if (likedPosts.contains(likeKey)) {
            // 👍 좋아요 취소
            likeCount = Math.max(0, currentLikes - 1);
            mgr.updateBoardLike(boardId, likeCount);
            likedPosts.remove(likeKey);
            liked = false;

            // 쿠키 삭제
            Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if (cookie.getName().equals("liked_post_" + boardId + "_" + encodedMemberId)) {
                        cookie.setMaxAge(0);
                        cookie.setPath("/");
                        response.addCookie(cookie);
                        break;
                    }
                }
            }
        } else {
            // ❤️ 좋아요 추가
            likeCount = currentLikes + 1;
            mgr.updateBoardLike(boardId, likeCount);
            likedPosts.add(likeKey);
            liked = true;

            Cookie cookie = new Cookie("liked_post_" + boardId + "_" + encodedMemberId, "true");
            cookie.setMaxAge(60 * 60 * 24 * 365); // 1년
            cookie.setPath("/");
            response.addCookie(cookie);
        }
    }

    out.print("{\"liked\": " + liked + ", \"likeCount\": " + likeCount + "}");
%>
