# algorithim implementation
[see wiki](https://en.wikipedia.org/wiki/Levenberg%E2%80%93Marquardt_algorithm)

Levenberg's contribution is to replace this equation by a "damped version", $`(J^TJ+\lambda I)=J^T(y-f(\beta))`$ where I is the identity matrix, giving as the increment δ to the estimated parameter vector β.

以下代码示例中，通过J计算出damping factor，再将待估计参数加上damping factor
```
% compute the approximated Hessian matrix, J’ is the transpose of J
H=J'*J;
% Apply the damping factor to the Hessian matrix
H_lm=H+(lamda*eye(Nparams,Nparams));
% Compute the updated parameters
dp=-inv(H_lm)*(J'*d(:));
a_lm=a_est+dp(1);
b_lm=b_est+dp(2);
```
A matlab demo pls ref "**A Memo on How to Use the Levenberg-Marquardt Algorithm for Refining Camera Calibration Parameters**"


# opencv demo
```
//curve fit problem for y=b0*(1-exp(-b1*x))

#include <opencv2/opencv.hpp>
#include <random>

using namespace std;
using namespace cv;

void make_samples(int num, double xlb, double xub, Mat param,
                  vector<Vec2d>& samples) {
    random_device rd;
    mt19937 mt(rd());
    uniform_real_distribution<double> vx(xlb, xub);

    auto beta1 = param.at<double>(0, 0);
    auto beta2 = param.at<double>(1, 0);

    for (auto i = 0; i < num; ++i) {
        auto x = vx(mt);
        auto y = beta1 * (1 - exp(-beta2 * x));
        samples.push_back(Vec2d(x, y));
    }
}

void calc_jacobian(Mat& jac, Mat& param, vector<Vec2d>& samples) {
    jac.create(samples.size(), 2, CV_64F);

    for (auto i = 0; i < samples.size(); ++i) {
        double b0 = param.at<double>(0, 0);
        double b1 = param.at<double>(1, 0);
        double x = samples.at(i)(0);
        jac.at<double>(i, 0) = (1.0 - exp(-b1 * x));
        jac.at<double>(i, 1) = (b0 * x * exp(-b1 * x));
    }
}

void calc_error(Mat& err, Mat& param, vector<Vec2d>& samples) {
    err.create(samples.size(), 1, CV_64F);

    for (auto i = 0; i < samples.size(); ++i) {
        double b0 = param.at<double>(0, 0);
        double b1 = param.at<double>(1, 0);
        double x = samples.at(i)(0);
        double y = samples.at(i)(1);
        err.at<double>(i, 0) = b0 * (1.0 - exp(-b1 * x)) - y;
    }
}

int main() {
    auto num = 100;
    auto xlb = 0.0;
    auto xub = 800.0;
    Mat gt_param = (Mat_<double>(2, 1) << 240.0, 0.0005);
    vector<Vec2d> samples;
    make_samples(num, xlb, xub, gt_param, samples);

    auto nparams = 2;
    auto nerrs = samples.size();
    auto criteria =
        cvTermCriteria(CV_TERMCRIT_EPS | CV_TERMCRIT_ITER, 30, DBL_EPSILON);
    auto complete_symm_flag = false;
    auto solver = CvLevMarq(nparams, nerrs, criteria, complete_symm_flag);

    Mat initial_param = (Mat_<double>(2, 1) << 400, 0.01);
    CvMat param = initial_param;

    Mat err, jac;
    cvCopy(&param, solver.param);

    int iter = 0;
    for (;;) {
        const CvMat* _param = 0;
        CvMat* _jac = 0;
        CvMat* _err = 0;

        bool proceed = solver.update(_param, _jac, _err);

        cvCopy(_param, &param);

        cout << "iter=" << iter << " state=" << solver.state
             << " errNorm=" << solver.errNorm << endl;

        if (!proceed || !_err) break;

        if (_jac) {
            Mat p = Mat(param.rows, param.cols, CV_64FC1, param.data.db);
            calc_jacobian(jac, p, samples);
            CvMat tmp = jac;
            cvCopy(&tmp, _jac);
        }

        if (_err) {
            Mat p = Mat(param.rows, param.cols, CV_64FC1, param.data.db);
            calc_error(err, p, samples);
            iter++;
            CvMat tmp = err;
            cvCopy(&tmp, _err);
        }
    }

    cout << "estimated param: " << endl;
    cout << Mat(param.rows, param.cols, CV_64FC1, param.data.db) << endl;
    cout << "GT param: " << endl;
    cout << gt_param << endl;

    return 0;
}
```