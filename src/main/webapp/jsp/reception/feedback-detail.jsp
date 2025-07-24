<div class="container mt-4">
    <h4>Feedback Detail</h4>
    <div class="card mb-3">
        <div class="card-body">
            <h5 class="card-title">Feedback #${feedback.id}</h5>
            <p><b>Customer:</b> ${feedback.userFullName} (${feedback.userEmail})</p>
            <p><b>Rating:</b> ${feedback.rating}</p>
            <p><b>Comment:</b> ${feedback.comment}</p>
            <p><b>Date:</b> ${feedback.createdAt}</p>
        </div>
    </div>
    <h5>Replies from Staff</h5>
    <c:choose>
        <c:when test="${not empty replies}">
            <c:forEach var="reply" items="${replies}">
                <div class="card mb-2">
                    <div class="card-body">
                        <b>${reply.name}</b> (${reply.email})<br>
                        <span>${reply.message}</span><br>
                        <small class="text-muted">${reply.createdAt}</small>
                    </div>
                </div>
            </c:forEach>
        </c:when>
        <c:otherwise>
            <div class="alert alert-info">No replies from staff yet.</div>
        </c:otherwise>
    </c:choose>
    <a href="${pageContext.request.contextPath}/receptionist/feedback" class="btn btn-secondary mt-3">Back to Feedback List</a>
</div> 