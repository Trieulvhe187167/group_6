<%@ page language="java" contentType="text/html; charset=UTF-8" import="java.util.List, dal.BlogDAO, model.Blog" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <!-- META -->
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="keywords" content="" />
        <meta name="author" content="" />
        <meta name="robots" content="" />
        <meta name="description" content="EduChamp : Education HTML Template" />
        <meta property="og:title" content="EduChamp : Education HTML Template" />
        <meta property="og:description" content="EduChamp : Education HTML Template" />
        <meta property="og:image" content="" />
        <meta name="format-detection" content="telephone=no">
        <link rel="icon" href="${pageContext.request.contextPath}/assets/images/favicon.ico" type="image/x-icon" />
        <link rel="shortcut icon" type="image/x-icon" href="${pageContext.request.contextPath}/assets/images/favicon.png" />
        <title>Blog Classic - Luxury Hotel</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <!-- CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/assets.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/typography.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shortcodes/shortcodes.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
        <link class="skin" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/color/color-1.css">
    </head>
    <body id="bg">
        <div class="page-wraper">
            <div id="loading-icon-bx"></div>
            <!-- Header -->
            <header class="header rs-nav">
                <!-- Top bar and nav (copy from static template) -->
                <%@ include file="header.jsp" %>
            </header>

            <!-- Inner Content Box -->
            <div class="page-content bg-white">
                <!-- Page Heading -->
                <div class="page-banner ovbl-dark" style="background-image:url(${pageContext.request.contextPath}/assets/images/banner/banner2.jpg);">
                    <div class="container">
                        <div class="page-banner-entry">
                            <h1 class="text-white">Blog</h1>
                        </div>
                    </div>
                </div>
                <div class="breadcrumb-row">
                    <div class="container">
                        <ul class="list-inline">
                            <li><a href="/index.jsp">Home</a></li>
                            <li>Blog</li>
                        </ul>
                    </div>
                </div>

                <!-- Blog Grid -->
                <div class="content-block">
                    <div class="section-area section-sp1">
                        <div class="container">
                            <div class="ttr-blog-grid-3">
                                <%
                                  // Load published blogs
                                  BlogDAO blogDao = new BlogDAO();
                                  List<Blog> blogs = blogDao.getPublishedBlogs();
                                  request.setAttribute("blogs", blogs);
                                %>
                                <c:forEach var="blog" items="${blogs}">
                                    <div class="post action-card m-b40">
                                        <div class="recent-news">
                                            <div class="action-box">
                          <!--                    <img src="${pageContext.request.contextPath}/assets/images/blog/${blog.imageUrl}" alt="${blog.title}" />-->
                                            </div>
                                            <div class="info-bx">
                                                <ul class="media-post">
                                                    <li><a href="#"><i class="fa fa-calendar"></i><fmt:formatDate value="${blog.createdAt}" pattern="MMM dd yyyy"/></a></li>
                                                    <li><a href="#"><i class="fa fa-user"></i>${blog.authorName}</a></li>
                                                </ul>
                                                <h5 class="post-title">
                                                    <a href="${pageContext.request.contextPath}/BlogDetailServlet?id=${blog.id}">
                                                        ${blog.title}
                                                    </a>
                                                </h5>
                                                <a href="${pageContext.request.contextPath}/BlogDetailServlet?id=${blog.id}"
                                                   class="btn-link">
                                                    READ MORE
                                                </a>

                                                <a href="#" class="comments-bx"><i class="fa fa-comments-o"></i>${blog.commentCount} Comment</a>
                                            </div>
                                        </div>
                                    </div>                            
                            </c:forEach>
                        </div>

                        <!-- Pagination -->
                        <div class="pagination-bx rounded-sm gray clearfix">
                            <ul class="pagination">
                                <li class="previous"><a href="#"><i class="ti-arrow-left"></i> Prev</a></li>
                                <li class="active"><a href="#">1</a></li>
                                <li><a href="#">2</a></li>
                                <li><a href="#">3</a></li>
                                <li class="next"><a href="#">Next <i class="ti-arrow-right"></i></a></li>
                            </ul>
                        </div>

                    </div>
                </div>
            </div>
         
        </div>
                                   <%@ include file="footer.jsp" %>
 </div>

        <!-- Footer -->




        <!-- JS -->
        <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap/js/popper.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap/js/bootstrap.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap-select/bootstrap-select.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap-touchspin/jquery.bootstrap-touchspin.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/magnific-popup/magnific-popup.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/counter/waypoints-min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/counter/counterup.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/imagesloaded/imagesloaded.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/masonry/masonry.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/masonry/filter.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/owl-carousel/owl.carousel.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/functions.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/contact.js"></script>
   

    </body>
</html>