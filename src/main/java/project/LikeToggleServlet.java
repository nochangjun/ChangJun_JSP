package project;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/project/rst/LikeToggleServlet")
public class LikeToggleServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        HttpSession session = request.getSession();
        String memberId = (String) session.getAttribute("idKey");
        String reviewIdStr = request.getParameter("review_id");

        int reviewId = 0;
        try {
            reviewId = Integer.parseInt(reviewIdStr);
        } catch (NumberFormatException e) {
            reviewId = -1;
        }

        ReviewLikeMgr likeMgr = new ReviewLikeMgr();
        ReviewLikeBean bean = new ReviewLikeBean();
        bean.setMember_id(memberId);
        bean.setReview_id(reviewId);

        boolean liked = false;
        int likeCount = 0;

        if (memberId != null && reviewId > 0) {
            liked = likeMgr.toggleLike(bean);
            likeCount = likeMgr.likeCount(reviewId);
        }

        // JSON 문자열 직접 만들기
        String json = "{"
                    + "\"success\": " + (memberId != null) + ","
                    + "\"liked\": " + liked + ","
                    + "\"newLikeCount\": " + likeCount
                    + "}";

        PrintWriter out = response.getWriter();
        out.print(json);
        out.close();
    }
}
