# Stable Cascaded Shadow Mapping

This shaderpack demonstrates a stable form of Cascaded Shadow Mapping, or CSM for short. While CSM has already been implemented in Minecraft shaderpacks several times before, this is to my knowledge the first implementation that is stable under camera motion, while also making reasonably efficient use of the available resolution.

Aside from the algorithm used to determine exact size & position of the cascades, this implementation takes a similar approach to previous implementations.

## The cascade size & positioning algorthm

Core idea: Set cascade radii, find maximal frustum slice far planes.

1. Set last cascade radius. In this implementation, this is the shadow distance setting, limited to the current render distance.
2. Set the cascade base, AKA the ratio between successive cascade radii. For clean transitions, there is a preferred cascade base. In order to ensure good detail for nearby objects, the first cascade also has a maximum radius, from which a cascade base will be calculated if necessary. In practice, the preferred cascade base usually requires too many cascades to reach sufficient resolution up close, so the base calculated from the maximum first cascade radius is nearly always used.
3. Set the near plane of the first cascade's frustum slice. This should be the near plane of the view frustum.
4. For each cascade:
    1. Set this cascade's radius.
    2. Set the far plane of this cascade's frustum slice such that the largest radius of the slice's AABB is equal to the cascade radius.
    3. Based on the center of the slice AABB, as well as the viewing direction component corresponding to the smaller axis of the AABB, set the cascade center.
    4. Expand this cascade's radius by a specific distance in blocks. This is done to accomodate filtering.
    5. Expand this cascade's radius by a specific distance in pixels. This is done to accomodate rounding the cascade's center to a tracked pixel grid, as well as to accomodate filtering.
    6. Update this cascade's tracked pixel grid offset.
    7. Round this cascade's center to the tracked pixel grid offset.
    8. Construct this cascade's final projection parameters based on its radius & center.

The margins added in steps 4.4 & 4.5 can also be added to a secondary radius to facilitate an "inner" margin, within which geometry is guaranteed to only affect this cascade or earlier cascades and can be culled for a small improvement to performance
