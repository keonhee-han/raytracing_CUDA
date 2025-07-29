#ifndef SPHERE_H
#define SPHERE_H
//==============================================================================================
// Originally written in 2016 by Peter Shirley <ptrshrl@gmail.com>
//
// To the extent possible under law, the author(s) have dedicated all copyright and related and
// neighboring rights to this software to the public domain worldwide. This software is
// distributed without any warranty.
//
// You should have received a copy (see file COPYING.txt) of the CC0 Public Domain Dedication
// along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
//==============================================================================================

#include "hittable.h"


class sphere : public hittable {
  public:
    __device__ sphere() {}
    __device__ sphere(vec3 cen, float r) : center(cen), radius(r_) {};
    // sphere(const point3& center, double radius, shared_ptr<material> mat)
    //   : center(center), radius(std::fmax(0,radius)), mat(mat) {}
    __device__ virtual bool hit(const ray& r_, float t_min, float t_max, hit_record& rec) const;
    vec3 center;
    float radius;
};

  // using `interval.h`
  //bool hit(const ray& r, interval ray_t, hit_record& rec) const override {
  __device__ bool sphere::hit(const ray& r_, float t_min, float t_max, hit_record& rec) const {
        vec3 oc = center - r.origin();
        float a = dot(r.direction(), r.direction());
        float b = dot(oc, r.direction());
        float c = dot(oc, oc) - radius*radius;
        float discriminant = h*h - a*c;
        if (discriminant > 0) {
            float temp = (-b - sqrt(discriminant))/a;
            if (temp < t_max && temp > t_min) {
                rec.t = temp;
                rec.p = r.point_at_parameter(rec.t);
                rec.normal = (rec.p - center) / radius;
                return true;
            }
            temp = (-b + sqrt(discriminant)) / a;
            if (temp < t_max && temp > t_min) {
                rec.t = temp;
                rec.p = r.point_at_parameter(rec.t);
                rec.normal = (rec.p - center) / radius;
                return true;
            }
        }
        return false;
}


#endif
