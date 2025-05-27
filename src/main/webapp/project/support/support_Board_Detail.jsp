<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, project.*"%>
<%@ page import="java.net.URLEncoder"%>
<jsp:useBean id="boardMgr" class="project.BoardMgr" />
<jsp:useBean id="commentMgr" class="project.CommentMgr" />
<%
    // 게시글 ID 받기
    int boardId = 0;
    try {
        boardId = Integer.parseInt(request.getParameter("id"));
    } catch (Exception e) {
        response.sendRedirect("support_Board.jsp");
        return;
    }

    // 세션에서 로그인한 사용자 ID 가져오기
    String memberId = (String) session.getAttribute("idKey");
    String encodedMemberId = "";
    if (memberId != null) {
        encodedMemberId = URLEncoder.encode(memberId, "UTF-8");
    }

    // 좋아요 여부를 체크하기 위한 Set (애플리케이션 컨텍스트에 저장)
    HashSet<String> likedPosts = (HashSet<String>) application.getAttribute("likedPosts");
    if (likedPosts == null) {
        likedPosts = new HashSet<String>();
        application.setAttribute("likedPosts", likedPosts);
    }

    HashSet<String> likedComments = (HashSet<String>) application.getAttribute("likedComments");
    if (likedComments == null) {
        likedComments = new HashSet<String>();
        application.setAttribute("likedComments", likedComments);
    }

    // 게시글 좋아요 처리
    if (request.getParameter("like") != null && memberId != null) {
        String likeKey = memberId + "_post_" + boardId;

        if (likedPosts.contains(likeKey)) {
            Integer currentLikes = boardMgr.getBoard(boardId).getBoard_like();
            if (currentLikes == null) currentLikes = 0;

            boardMgr.updateBoardLike(boardId, Math.max(0, currentLikes - 1));
            likedPosts.remove(likeKey);
            application.setAttribute("likedPosts", likedPosts);

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
            Integer currentLikes = boardMgr.getBoard(boardId).getBoard_like();
            if (currentLikes == null) currentLikes = 0;

            boardMgr.updateBoardLike(boardId, currentLikes + 1);
            likedPosts.add(likeKey);
            application.setAttribute("likedPosts", likedPosts);

            Cookie likeCookie = new Cookie("liked_post_" + boardId + "_" + encodedMemberId, "true");
            likeCookie.setMaxAge(Integer.MAX_VALUE);
            likeCookie.setPath("/");
            response.addCookie(likeCookie);
        }

        response.sendRedirect("support_Board_Detail.jsp?id=" + boardId);
        return;
    }

    // 댓글 좋아요 처리
    if (request.getParameter("commentLike") != null && memberId != null) {
        int commentId = Integer.parseInt(request.getParameter("commentId"));
        String likeKey = memberId + "_comment_" + commentId;

        if (likedComments.contains(likeKey)) {
            commentMgr.decrementLike(commentId);
            likedComments.remove(likeKey);
            application.setAttribute("likedComments", likedComments);

            Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if (cookie.getName().equals("liked_comment_" + commentId + "_" + encodedMemberId)) {
                        cookie.setMaxAge(0);
                        cookie.setPath("/");
                        response.addCookie(cookie);
                        break;
                    }
                }
            }
        } else {
            commentMgr.incrementLike(commentId);
            likedComments.add(likeKey);
            application.setAttribute("likedComments", likedComments);

            Cookie likeCookie = new Cookie("liked_comment_" + commentId + "_" + memberId, "true");
            likeCookie.setMaxAge(Integer.MAX_VALUE);
            likeCookie.setPath("/");
            response.addCookie(likeCookie);
        }

        response.sendRedirect("support_Board_Detail.jsp?id=" + boardId);
        return;
    }

    // 조회수 증가
    boardMgr.increaseViewCount(boardId);

    // 게시글 상세 정보 가져오기
    BoardBean board = boardMgr.getBoard(boardId);

    if (board == null) {
        response.sendRedirect("support_Board.jsp");
        return;
    }

    // 게시글 삭제 처리
    if (request.getParameter("action") != null && request.getParameter("action").equals("delete")) {
        if (board.getMember_id().equals(memberId)) {
            boardMgr.deleteBoard(boardId);
        }
        response.sendRedirect("support_Board.jsp");
        return;
    }

    // 댓글 목록 가져오기
    Vector<CommentBean> commentList = commentMgr.getCommentList(boardId);
    int commentCount = commentList.size();

    // 이전글과 다음글 가져오기
    BoardBean prevBoard = boardMgr.getPrevBoard(boardId);
    BoardBean nextBoard = boardMgr.getNextBoard(boardId);

    // 쿠키에서 좋아요 정보 읽어오기
    boolean postLiked = false;
    Cookie[] cookies = request.getCookies();
    if (memberId != null && cookies != null) {
        for (Cookie cookie : cookies) {
            if (cookie.getName().equals("liked_post_" + boardId + "_" + encodedMemberId)) {
                postLiked = true;
                likedPosts.add(encodedMemberId + "_post_" + boardId);
                break;
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>게시글 상세보기</title>
    <link rel="stylesheet" type="text/css" href="../css/support_Board_Detail.css">
    <jsp:include page="../header.jsp"></jsp:include>
</head>
<body>
    <div class="container">
        <h2 class="title">게시글</h2>

        <div class="post-header">
            <div class="post-info">
                <div class="post-title">
                    <span class="label">제목</span>
                    <span class="content"><%=board.getBoard_title()%></span>
                </div>
                <div class="post-meta">
                    <span class="date">작성일 <%=board.getBoard_at()%></span>
                    <%
                    if (memberId != null && board.getMember_id().equals(memberId)) {
                    %>
                    <div class="dropdown">
                        <button class="menu-icon">☰</button>
                        <div class="dropdown-content">
                            <button class="edit-btn" id="editBtn" onclick="editPost(<%=boardId%>)">수정</button>
                            <button class="delete-btn" id="deleteBtn">삭제</button>
                        </div>
                    </div>
                    <%
                    } else if (memberId != null) {
                    %>
                    <div class="report-dropdown">
                        <img src="../img/report.png" alt="신고" class="report-icon" onclick="showReportMenu('board', <%=boardId%>)">
                        <div class="report-dropdown-content" id="report-menu-board-<%=boardId%>">
                            <a class="report-reason" onclick="showReportForm('board', <%=boardId%>, '불건전한 내용')">불건전한 내용</a>
                            <a class="report-reason" onclick="showReportForm('board', <%=boardId%>, '욕설/비방')">욕설/비방</a>
                            <a class="report-reason" onclick="showReportForm('board', <%=boardId%>, '광고/홍보')">광고/홍보</a>
                            <a class="report-reason" onclick="showReportForm('board', <%=boardId%>, '개인정보 노출')">개인정보 노출</a>
                            <a class="report-reason" onclick="showReportForm('board', <%=boardId%>, '기타')">기타</a>
                        </div>
                    </div>
                    <%
                    }
                    %>
                </div>
            </div>
            <div class="header-divider"></div>
        </div>

        <div class="post-content" id="post-content-text">
            <%=board.getBoard_content()%>
        </div>

        <div class="post-footer">
            <div class="post-likes-section">
                <%
                String likedClass = postLiked ? "liked" : "";
                String postHeartSrc = postLiked ? "../img/heart.png" : "../img/heart_empty.png";
                %>
                <button class="post-btn-like <%=likedClass%>" id="postLikeBtn">
                    <img src="<%=postHeartSrc%>" alt="좋아요" class="post-icon-like" id="postHeartIcon">
                    <span class="post-like-count" id="postLikeCount"><%= (board.getBoard_like() != null) ? board.getBoard_like() : 0 %></span>
                </button>
            </div>
        </div>

        <div class="separator"></div>

        <div class="reply-section">
            <h3 class="reply-title">
                댓글 목록 <span class="reply-count" id="commentCount"><%=commentCount%></span>
            </h3>

            <%
            if (memberId != null) {
            %>
            <form action="support_Board_Comment_Process.jsp" method="post" class="reply-form">
                <input type="hidden" name="action" value="insert">
                <input type="hidden" name="boardId" value="<%=boardId%>">
                <input type="text" class="reply-input" name="content" id="replyText" placeholder="댓글을 입력하세요...">
                <button type="submit" class="reply-submit" id="submitReply">등록</button>
            </form>
            <%
            } else {
            %>
            <div class="login-required">
                댓글을 작성하려면 <a href="../login/login.jsp">로그인</a>이 필요합니다.
            </div>
            <%
            }
            %>

            <div class="reply-list" id="commentList">
                <%
                if (commentList.size() == 0) {
                %>
                <div class="no-comment">등록된 댓글이 없습니다.</div>
                <%
                } else {
                    for (int i = 0; i < commentList.size(); i++) {
                        CommentBean comment = commentList.get(i);
                        boolean isParentComment = comment.getParent_comment_id() == null;

                        if (isParentComment) {
                %>
                <div class="comment-item" id="comment-<%=comment.getComment_id()%>">
                    <div class="comment-header">
                        <div class="comment-info">
                            <span class="comment-nickname"><%=comment.getMember_nickname()%></span>
                            <span class="comment-date"><%=comment.getComment_at()%></span>
                        </div>
                    </div>
                    <div class="comment-content"><%=comment.getComment_content()%></div>
                    <div class="comment-actions">
                        <%
                        if (memberId != null) {
                            try {
                                encodedMemberId = URLEncoder.encode(memberId, "UTF-8");
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }

                        boolean commentLiked = false;
                        if (cookies != null) {
                            for (Cookie cookie : cookies) {
                                if (cookie.getName().equals("liked_comment_" + comment.getComment_id() + "_" + encodedMemberId)) {
                                    commentLiked = true;
                                    likedComments.add(encodedMemberId + "_comment_" + comment.getComment_id());
                                    break;
                                }
                            }
                        }
                        String commentLikedClass = commentLiked ? "liked" : "";
                        String commentHeartSrc = commentLiked ? "../img/heart.png" : "../img/heart_empty.png";
                        %>
                        <div class="comment-action-left">
                            <a href="#" class="comment-like <%=commentLikedClass%>" data-comment-id="<%=comment.getComment_id()%>">
                                <img src="<%=commentHeartSrc%>" alt="좋아요" class="like-icon" id="commentHeartIcon-<%=comment.getComment_id()%>">
                                <span class="like-count"><%=comment.getComment_like()%></span>
                            </a>
                            <%
                            if (memberId != null && !memberId.equals(comment.getMember_id())) {
                            %>
                            <div class="report-dropdown">
                                <img src="../img/report.png" alt="신고" class="report-icon" onclick="showReportMenu('comment', <%=comment.getComment_id()%>)">
                                <div class="report-dropdown-content" id="report-menu-comment-<%=comment.getComment_id()%>">
                                    <a class="report-reason" onclick="showReportForm('comment', <%=comment.getComment_id()%>, '불건전한 내용')">불건전한 내용</a>
                                    <a class="report-reason" onclick="showReportForm('comment', <%=comment.getComment_id()%>, '욕설/비방')">욕설/비방</a>
                                    <a class="report-reason" onclick="showReportForm('comment', <%=comment.getComment_id()%>, '광고/홍보')">광고/홍보</a>
                                    <a class="report-reason" onclick="showReportForm('comment', <%=comment.getComment_id()%>, '개인정보 노출')">개인정보 노출</a>
                                    <a class="report-reason" onclick="showReportForm('comment', <%=comment.getComment_id()%>, '기타')">기타</a>
                                </div>
                            </div>
                            <%
                            }
                            %>
                        </div>
                        <div class="comment-buttons">
                            <%
                            if (memberId != null) {
                            %>
                            <button class="comment-btn" onclick="showReplyForm(<%=comment.getComment_id()%>)">답글</button>
                            <%
                            if (memberId.equals(comment.getMember_id())) {
                            %>
                            <button class="comment-btn" onclick="showEditForm(<%=comment.getComment_id()%>, '<%=comment.getComment_content().replace("'", "\\'").replace("\n", "\\n")%>')">수정</button>
                            <button class="comment-btn" onclick="deleteComment(<%=comment.getComment_id()%>)">삭제</button>
                            <%
                            }
                            %>
                            <%
                            }
                            %>
                        </div>
                    </div>

                    <div class="edit-form-container" id="edit-form-<%=comment.getComment_id()%>">
                        <form action="support_Board_Comment_Process.jsp" method="post">
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" name="boardId" value="<%=boardId%>">
                            <input type="hidden" name="commentId" value="<%=comment.getComment_id()%>">
                            <textarea class="edit-textarea" name="content" id="edit-content-<%=comment.getComment_id()%>"><%=comment.getComment_content()%></textarea>
                            <div class="edit-buttons">
                                <button type="button" class="edit-cancel" onclick="hideEditForm(<%=comment.getComment_id()%>)">취소</button>
                                <button type="submit" class="edit-submit">수정</button>
                            </div>
                        </form>
                    </div>

                    <div class="reply-form-container" id="reply-form-<%=comment.getComment_id()%>">
                        <form action="support_Board_Comment_Process.jsp" method="post">
                            <input type="hidden" name="action" value="insert">
                            <input type="hidden" name="boardId" value="<%=boardId%>">
                            <input type="hidden" name="parentId" value="<%=comment.getComment_id()%>">
                            <textarea class="reply-textarea" name="content" id="reply-content-<%=comment.getComment_id()%>" placeholder="답글을 입력하세요..."></textarea>
                            <div class="reply-buttons">
                                <button type="button" class="reply-cancel-btn" onclick="hideReplyForm(<%=comment.getComment_id()%>)">취소</button>
                                <button type="submit" class="reply-submit-btn">등록</button>
                            </div>
                        </form>
                    </div>

                    <%
                    for (int j = 0; j < commentList.size(); j++) {
                        CommentBean reply = commentList.get(j);
                        if (reply.getParent_comment_id() != null && reply.getParent_comment_id() == comment.getComment_id()) {
                    %>
                    <div class="comment-item reply-comment" id="comment-<%=reply.getComment_id()%>">
                        <div class="comment-header">
                            <div class="comment-info">
                                <span class="comment-nickname"><%=reply.getMember_nickname()%></span>
                                <span class="comment-date"><%=reply.getComment_at()%></span>
                            </div>
                        </div>
                        <div class="comment-content"><%=reply.getComment_content()%></div>
                        <div class="comment-actions">
                            <%
                            boolean replyLiked = false;
                            if (memberId != null) {
                                try {
                                    encodedMemberId = URLEncoder.encode(memberId, "UTF-8");
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                            }
                            if (cookies != null) {
                                for (Cookie cookie : cookies) {
                                    if (cookie.getName().equals("liked_comment_" + reply.getComment_id() + "_" + encodedMemberId)) {
                                        replyLiked = true;
                                        likedComments.add(encodedMemberId + "_comment_" + reply.getComment_id());
                                        break;
                                    }
                                }
                            }
                            String replyLikedClass = replyLiked ? "liked" : "";
                            String replyHeartSrc = replyLiked ? "../img/heart.png" : "../img/heart_empty.png";
                            %>
                            <div class="comment-action-left">
                                <a href="#" class="comment-like <%=replyLikedClass%>" data-comment-id="<%=reply.getComment_id()%>">
                                    <img src="<%=replyHeartSrc%>" alt="좋아요" class="like-icon" id="commentHeartIcon-<%=reply.getComment_id()%>">
                                    <span class="like-count"><%=reply.getComment_like()%></span>
                                </a>
                                <%
                                if (memberId != null && !memberId.equals(reply.getMember_id())) {
                                %>
                                <div class="report-dropdown">
                                    <img src="../img/report.png" alt="신고" class="report-icon" onclick="showReportMenu('comment', <%=reply.getComment_id()%>)">
                                    <div class="report-dropdown-content" id="report-menu-comment-<%=reply.getComment_id()%>">
                                        <a class="report-reason" onclick="showReportForm('comment', <%=reply.getComment_id()%>, '불건전한 내용')">불건전한 내용</a>
                                        <a class="report-reason" onclick="showReportForm('comment', <%=reply.getComment_id()%>, '욕설/비방')">욕설/비방</a>
                                        <a class="report-reason" onclick="showReportForm('comment', <%=reply.getComment_id()%>, '광고/홍보')">광고/홍보</a>
                                        <a class="report-reason" onclick="showReportForm('comment', <%=reply.getComment_id()%>, '개인정보 노출')">개인정보 노출</a>
                                        <a class="report-reason" onclick="showReportForm('comment', <%=reply.getComment_id()%>, '기타')">기타</a>
                                    </div>
                                </div>
                                <%
                                }
                                %>
                            </div>
                            <div class="comment-buttons">
                                <%
                                if (memberId != null && memberId.equals(reply.getMember_id())) {
                                %>
                                <button class="comment-btn" onclick="showEditForm(<%=reply.getComment_id()%>, '<%=reply.getComment_content().replace("'", "\\'").replace("\n", "\\n")%>')">수정</button>
                                <button class="comment-btn" onclick="deleteComment(<%=reply.getComment_id()%>)">삭제</button>
                                <%
                                }
                                %>
                            </div>
                        </div>

                        <div class="edit-form-container" id="edit-form-<%=reply.getComment_id()%>">
                            <form action="support_Board_Comment_Process.jsp" method="post">
                                <input type="hidden" name="action" value="update">
                                <input type="hidden" name="boardId" value="<%=boardId%>">
                                <input type="hidden" name="commentId" value="<%=reply.getComment_id()%>">
                                <textarea class="edit-textarea" name="content" id="edit-content-<%=reply.getComment_id()%>"><%=reply.getComment_content()%></textarea>
                                <div class="edit-buttons">
                                    <button type="button" class="edit-cancel" onclick="hideEditForm(<%=reply.getComment_id()%>)">취소</button>
                                    <button type="submit" class="edit-submit">수정</button>
                                </div>
                            </form>
                        </div>
                    </div>
                    <%
                        }
                    }
                    %>
                </div>
                <%
                        }
                    }
                }
                %>
            </div>
        </div>

        <div class="related-posts">
            <h3 class="related-title">다른 글</h3>
            <%
            if (nextBoard != null) {
            %>
            <div class="related-item" onclick="location.href='support_Board_Detail.jsp?id=<%=nextBoard.getBoard_id()%>';" style="cursor: pointer;">
                <div class="related-label">다음</div>
                <div class="related-content"><%=nextBoard.getBoard_title()%></div>
                <div class="related-date"><%=nextBoard.getBoard_at().substring(0, 10)%></div>
            </div>
            <%
            } else {
            %>
            <div class="related-item">
                <div class="related-label">다음</div>
                <div class="related-content">다음 글이 없습니다</div>
                <div class="related-date">-</div>
            </div>
            <%
            }
            %>

            <%
            if (prevBoard != null) {
            %>
            <div class="related-item" onclick="location.href='support_Board_Detail.jsp?id=<%=prevBoard.getBoard_id()%>';" style="cursor: pointer;">
                <div class="related-label">이전</div>
                <div class="related-content"><%=prevBoard.getBoard_title()%></div>
                <div class="related-date"><%=prevBoard.getBoard_at().substring(0, 10)%></div>
            </div>
            <%
            } else {
            %>
            <div class="related-item">
                <div class="related-label">이전</div>
                <div class="related-content">이전 글이 없습니다</div>
                <div class="related-date">-</div>
            </div>
            <%
            }
            %>
        </div>

        <div class="button-container">
            <button type="button" onclick="location.href='support_Board.jsp'" class="list-button">목 록</button>
        </div>
    </div>

    <div class="report-form-overlay" id="report-form-overlay">
        <div class="report-form-container">
            <div class="report-form-title">신고하기</div>
            <form action="support_Board_Report_Process.jsp" method="post" class="report-form" id="report-form">
                <input type="hidden" name="action" value="report">
                <input type="hidden" name="reportType" id="report-type" value="">
                <input type="hidden" name="targetId" id="report-target-id" value="">
                <input type="hidden" name="boardId" value="<%=boardId%>">
                <textarea name="reason" id="report-reason" placeholder="신고 사유를 입력하세요..." required></textarea>
                <div class="report-form-buttons">
                    <button type="button" class="report-cancel" onclick="hideReportForm()">취소</button>
                    <button type="submit" class="report-submit">신고</button>
                </div>
            </form>
        </div>
    </div>

    <jsp:include page="../footer.jsp"></jsp:include>

    <script>
        // 페이지 로드 시 신고 폼 숨기기
        document.addEventListener('DOMContentLoaded', function() {
            var overlay = document.getElementById('report-form-overlay');
            if (overlay) {
                overlay.style.display = 'none';
            }
        });

        // 삼단바 메뉴 클릭 이벤트
        var menuIcon = document.querySelector('.menu-icon');
        if (menuIcon) {
            menuIcon.addEventListener('click', function() {
                var dropdown = this.nextElementSibling;
                dropdown.style.display = dropdown.style.display === 'block' ? 'none' : 'block';
            });
        }

        // 페이지의 다른 부분 클릭 시 드롭다운 닫기
        window.addEventListener('click', function(event) {
            if (!event.target.matches('.menu-icon') && !event.target.matches('.report-icon')) {
                var dropdowns = document.querySelectorAll('.dropdown-content, .report-dropdown-content');
                for (var i = 0; i < dropdowns.length; i++) {
                    if (dropdowns[i].style.display === 'block') {
                        dropdowns[i].style.display = 'none';
                    }
                }
            }
        });

        // 게시글 수정 함수
        function editPost(postId) {
            var postContentElem = document.getElementById('post-content-text');
            var currentContent = postContentElem.textContent.trim();
            var contentTextarea = document.createElement('textarea');
            contentTextarea.className = 'edit-post-content';
            contentTextarea.value = currentContent;
            var editControls = document.createElement('div');
            editControls.className = 'post-edit-controls';
            var saveButton = document.createElement('button');
            saveButton.textContent = '저장';
            saveButton.className = 'edit-save-btn';
            var cancelButton = document.createElement('button');
            cancelButton.textContent = '취소';
            cancelButton.className = 'edit-cancel-btn';
            editControls.appendChild(saveButton);
            editControls.appendChild(cancelButton);
            var originalContent = postContentElem.innerHTML;
            postContentElem.innerHTML = '';
            postContentElem.appendChild(contentTextarea);
            postContentElem.appendChild(editControls);

            saveButton.addEventListener('click', function() {
                var newContent = contentTextarea.value.trim();
                if (newContent !== '') {
                    location.href = 'support_Board_Update.jsp?id=' + postId + '&content=' + encodeURIComponent(newContent);
                } else {
                    alert('내용을 입력해주세요.');
                    postContentElem.innerHTML = originalContent;
                }
            });

            cancelButton.addEventListener('click', function() {
                postContentElem.innerHTML = originalContent;
            });

            var dropdown = document.querySelector('.dropdown-content');
            if (dropdown) {
                dropdown.style.display = 'none';
            }
        }

        // 삭제 버튼 클릭 이벤트
        var deleteBtn = document.getElementById('deleteBtn');
        if (deleteBtn) {
            deleteBtn.addEventListener('click', function() {
                if (confirm('삭제하시겠습니까?')) {
                    location.href = 'support_Board_Detail.jsp?id=<%=boardId%>&action=delete';
                }
            });
        }

        // 게시글 좋아요
        var postLikeBtn = document.getElementById('postLikeBtn');
        var postHeartIcon = document.getElementById('postHeartIcon');
        postLikeBtn.addEventListener('click', function () {
            fetch('support_Like_Post.jsp?boardId=' + <%=boardId%>)
                .then(res => res.json())
                .then(data => {
                    if (data.error) {
                        document.getElementById("yummy-loginAlertModal").style.display = "flex";
                        return;
                    }
                    if (data) {
                        document.getElementById('postLikeCount').textContent = data.likeCount;
                        postLikeBtn.classList.toggle('liked', data.liked);
                        if (postHeartIcon) {
                            postHeartIcon.src = data.liked ? '../img/heart.png' : '../img/heart_empty.png';
                        }
                    }
                })
                .catch(err => console.error('좋아요 처리 오류:', err));
        });

        // 댓글 수정 폼 표시
        function showEditForm(commentId) {
            var editForm = document.getElementById('edit-form-' + commentId);
            if (editForm) {
                editForm.style.display = 'block';
            }
        }

        // 댓글 수정 폼 숨기기
        function hideEditForm(commentId) {
            var editForm = document.getElementById('edit-form-' + commentId);
            if (editForm) {
                editForm.style.display = 'none';
            }
        }

        // 댓글 삭제 처리
        function deleteComment(commentId) {
            if (confirm('댓글을 삭제하시겠습니까?')) {
                var form = document.createElement('form');
                form.method = 'POST';
                form.action = 'support_Board_Comment_Process.jsp';
                var actionField = document.createElement('input');
                actionField.type = 'hidden';
                actionField.name = 'action';
                actionField.value = 'delete';
                form.appendChild(actionField);
                var boardIdField = document.createElement('input');
                boardIdField.type = 'hidden';
                boardIdField.name = 'boardId';
                boardIdField.value = '<%=boardId%>';
                form.appendChild(boardIdField);
                var commentIdField = document.createElement('input');
                commentIdField.type = 'hidden';
                commentIdField.name = 'commentId';
                commentIdField.value = commentId;
                form.appendChild(commentIdField);
                document.body.appendChild(form);
                form.submit();
            }
        }

        // 답글 폼 표시
        function showReplyForm(commentId) {
            var replyForm = document.getElementById('reply-form-' + commentId);
            if (replyForm) {
                replyForm.style.display = 'block';
                document.getElementById('reply-content-' + commentId).focus();
            }
        }

        // 답글 폼 숨기기
        function hideReplyForm(commentId) {
            var replyForm = document.getElementById('reply-form-' + commentId);
            if (replyForm) {
                replyForm.style.display = 'none';
            }
        }

        // 신고 메뉴 표시
        function showReportMenu(type, targetId) {
            var reportMenuId = 'report-menu-' + type + '-' + targetId;
            var reportMenu = document.getElementById(reportMenuId);
            if (reportMenu) {
                var allMenus = document.querySelectorAll('.report-dropdown-content');
                for (var i = 0; i < allMenus.length; i++) {
                    if (allMenus[i] !== reportMenu) {
                        allMenus[i].style.display = 'none';
                    }
                }
                reportMenu.style.display = reportMenu.style.display === 'block' ? 'none' : 'block';
            }
        }

        // 신고 폼 표시
        function showReportForm(type, targetId, reason) {
            var overlay = document.getElementById('report-form-overlay');
            var reportTypeInput = document.getElementById('report-type');
            var targetIdInput = document.getElementById('report-target-id');
            var reasonInput = document.getElementById('report-reason');

            if (overlay && reportTypeInput && targetIdInput && reasonInput) {
                reportTypeInput.value = type;
                targetIdInput.value = targetId;
                reasonInput.value = reason;
                overlay.style.display = 'flex';

                // 모든 신고 메뉴 닫기
                var allMenus = document.querySelectorAll('.report-dropdown-content');
                for (var i = 0; i < allMenus.length; i++) {
                    allMenus[i].style.display = 'none';
                }
            }
        }

        // 신고 폼 숨기기
        function hideReportForm() {
            var overlay = document.getElementById('report-form-overlay');
            var reasonInput = document.getElementById('report-reason');
            if (overlay && reasonInput) {
                overlay.style.display = 'none';
                reasonInput.value = ''; // 입력값 초기화
            }
        }

        // 로그인 페이지로 이동
        function goToLogin() {
            const currentUrl = window.location.pathname + window.location.search;
            const encodedUrl = encodeURIComponent(currentUrl);
            window.location.href = "<%=request.getContextPath()%>/project/login/login.jsp?url=" + encodedUrl;
        }

        // 로그인 경고 모달 닫기
        function closeLoginModal() {
            document.getElementById("yummy-loginAlertModal").style.display = "none";
        }

        // 댓글 좋아요 토글
        document.querySelectorAll('.comment-like').forEach(function (btn) {
            btn.addEventListener('click', function (e) {
                e.preventDefault();
                const commentId = this.dataset.commentId;
                const likeCountSpan = this.querySelector('.like-count');
                const heartIcon = document.getElementById('commentHeartIcon-' + commentId);
                const that = this;

                fetch('support_Like_Comment.jsp?commentId=' + commentId)
                    .then(res => res.json())
                    .then(data => {
                        if (data.error) {
                            document.getElementById("yummy-loginAlertModal").style.display = "flex";
                            return;
                        }
                        if (data) {
                            likeCountSpan.textContent = data.likeCount;
                            that.classList.toggle('liked', data.liked);
                            if (heartIcon) {
                                heartIcon.src = data.liked ? '../img/heart.png' : '../img/heart_empty.png';
                            }
                        }
                    })
                    .catch(err => console.error('댓글 좋아요 오류:', err));
            });
        });
    </script>
</body>
</html>