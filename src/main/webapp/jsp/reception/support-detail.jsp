<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Support Request Detail</title>
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    </head>
    <body >

        <h2>Support Request Detail</h2>

        <br>
        <a href="support?action=list" class="btn btn-secondary">Back to List</a>
        <div class="row">
            <div class="col-md-6">
                <h4 class="mt-4">Detail</h4>
                <div class="card mb-4">
                    <div class="card-body">
                        <h5 class="card-title">${supportRequest.title}</h5>
                        <p><strong>Request ID:</strong> ${supportRequest.id}</p>
                        <p><strong>User:</strong> ${supportRequest.userName}</p>
                        <p><strong>Room:</strong> ${supportRequest.roomNumber}</p>
                        <p><strong>Description:</strong> ${supportRequest.description}</p>
                        <p><strong>Status:</strong> ${supportRequest.status}</p>
                        <p><strong>Created At:</strong> 
                            <fmt:formatDate value="${supportRequest.createdAt}" pattern="yyyy-MM-dd HH:mm" />
                        </p>
                    </div>
                </div>

                <!-- Danh sách phản hồi -->
                <h4>Replies</h4>
                <c:choose>
                    <c:when test="${not empty replies}">
                        <c:forEach var="reply" items="${replies}">
                            <div class="card mb-2">
                                <div class="card-body">
                                    <p>${reply.message}</p>
                                    <small class="text-muted">
                                        By: ${reply.staffName} |
                                        <fmt:formatDate value="${reply.createdAt}" pattern="yyyy-MM-dd HH:mm"/>
                                    </small>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <p>No replies yet.</p>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="col-md-6">


                <!-- Form phản hồi + cập nhật trạng thái -->
                <h4 class="mt-4">Add a Reply</h4>
                <form action="support" method="post">
                    <input type="hidden" name="action" value="reply">
                    <input type="hidden" name="requestId" value="${supportRequest.id}">

                    <div class="form-group mt-3">
                        <label for="status">Update Status</label>
                        <select name="status" class="form-control" required>
                            <option value="Pending" ${supportRequest.status == 'Pending' ? 'selected' : ''}>Pending</option>
                            <option value="In Progress" ${supportRequest.status == 'In Progress' ? 'selected' : ''}>In Progress</option>
                            <option value="Resolved" ${supportRequest.status == 'Resolved' ? 'selected' : ''}>Resolved</option>
                            <option value="Rejected" ${supportRequest.status == 'Rejected' ? 'selected' : ''}>Rejected</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="message">Your Message</label>
                        <textarea name="message" class="form-control" rows="4" required></textarea>
                    </div>

                    <button type="submit" class="btn btn-primary">Send Reply</button>
                </form>
            </div>
        </div>

    </body>
</html>
