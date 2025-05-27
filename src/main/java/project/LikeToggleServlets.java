package project;
import java.io.IOException;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONObject;

@WebServlet("/LikeToggleServlets")
public class LikeToggleServlets extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        HttpSession session = request.getSession();
        String memberId = (String) session.getAttribute("idKey");
        String likeType = request.getParameter("likeType");  // 'course', 'review', 'restaurant'
        String targetIdStr = request.getParameter("targetId");

        JSONObject json = new JSONObject();

        if (memberId == null || likeType == null || targetIdStr == null) {
            json.put("success", false);
            json.put("error", "필수 정보 누락");
            response.getWriter().print(json);
            return;
        }

        int targetId = Integer.parseInt(targetIdStr);

        LikeMgr likeMgr = new LikeMgr();
        boolean liked = likeMgr.toggleLike(memberId, likeType, targetId);
        int count = likeMgr.getLikeCount(likeType, targetId);

        json.put("success", true);  // ✅ 추가됨
        json.put("liked", liked);
        json.put("likeCount", count);  // ✅ key 이름 통일

        response.getWriter().print(json);
    }
}
