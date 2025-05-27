package project;

import java.io.File;
import java.io.IOException;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import javax.servlet.http.Part;

import com.mysql.cj.Session;


@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,       // 메모리에서 파일로 전환되는 크기 (1MB)
    maxFileSize = 1024 * 1024 * 5,         // 업로드 파일 최대 크기 (5MB)
    maxRequestSize = 1024 * 1024 * 25      // 전체 요청의 최대 크기 (25MB)
)
@WebServlet("/project/rst/ReviewWriteServlet")

public class ReviewWriteServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	// 업로드된 파일 저장 경로 (웹서버 기준)
    private static final String SAVE_DIR = "upload/review";

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/plain; charset=UTF-8");
		
		 // 1. 사용자 입력값 받기 (review_menu, rating 등)
        String rstId = request.getParameter("rst_id");
        String reviewMenu = request.getParameter("review_menu");
        String rating = request.getParameter("rating");
        String content = request.getParameter("review_content");
        String member_id = (String) request.getSession().getAttribute("idKey");
        
        ReviewBean rBean = new ReviewBean();
        rBean.setRst_id(Integer.parseInt(rstId));
        rBean.setReview_menu(reviewMenu);
        rBean.setReview_rating(Double.parseDouble(rating));
        rBean.setReview_comment(content);
        rBean.setMember_id(member_id);
        
        ReviewMgr mgr = new ReviewMgr();
        mgr.insertReview(rBean);
        rBean.setReview_id(mgr.searchReviewId(rstId, member_id));
        // 2. 서버 파일 저장 경로 생성
        String uploadPath = getServletContext().getRealPath("") + File.separator + SAVE_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs(); // 폴더가 없으면 자동 생성
        }

        // 3. 여러 파일 처리
        for (Part part : request.getParts()) {
            if (part.getName().equals("review_photos") && part.getSize() > 0) {
                // 원래 파일 이름
                String originalFileName = getFileName(part);

                // UUID로 중복 방지된 새 파일 이름 생성
                String uniqueName = UUID.randomUUID().toString() + "_" + originalFileName;

                // 실제 서버 경로에 파일 저장
                part.write(uploadPath + File.separator + uniqueName);

                // DB에 저장할 상대 경로
                String filePathForDB = SAVE_DIR + "/" + uniqueName;

                // 여기서 DB 저장 로직 실행
                //saveToDatabase(rstId, userId, reviewMenu, rating, content, latitude, longitude, photoDate, filePathForDB);
                mgr.insertReviewImage(rBean, filePathForDB);
                
            }
        }

        // 저장 후 성공 페이지로 이동
        response.sendRedirect("../rst/rst_Detail.jsp?rst_id="+rstId);
    }

    // 파일 이름 추출 메소드
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        for (String s : contentDisp.split(";")) {
            if (s.trim().startsWith("filename")) {
                return s.substring(s.indexOf("=") + 2, s.length() - 1);
            }
        }
        return "";
    }

}
